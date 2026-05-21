import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/core/realtime/realtime_event_bus.dart';
import 'package:t_app/features/post_detail/data/mock_thread_repository.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/posts/data/thread_api_mapper.dart';
import 'package:t_app/features/posts/domain/posts_feed_repository.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required PostsFeedRepository repository})
    : _repository = repository,
      super(const HomeState()) {
    _realtimeSubscription = RealtimeEventBus.instance.stream.listen(
      _handleRealtimeEvent,
    );
  }

  final PostsFeedRepository _repository;
  late final StreamSubscription<RealtimeAppEvent> _realtimeSubscription;

  Future<void> loadHomeFeed() async {
    if (AppConfig.uiPreviewMode) {
      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: const MockThreadRepository().fetchRootThreads(),
          lastLoadedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: HomeFeedStatus.loading, clearError: true));

    try {
      final page = await _repository.getFeed();
      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: page.items,
          lastLoadedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          status: HomeFeedStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeFeedStatus.failure,
          errorMessage: 'Không thể tải bảng tin.',
        ),
      );
    }
  }

  /// Creates a new post and prepends it to the current feed.
  Future<void> createPost(
    String content, {
    List<String> mediaUrls = const <String>[],
  }) async {
    if (AppConfig.uiPreviewMode) {
      final trimmed = content.trim();
      if (trimmed.isEmpty) {
        return;
      }

      final postId = 'preview_post_${DateTime.now().microsecondsSinceEpoch}';
      final post = ThreadItemModel(
        id: postId,
        rootThreadId: postId,
        author: const User(
          id: 'demo_user',
          name: 'Thaii Duong',
          username: '__win.d',
          avatarAssetPath: 'assets/images/home_avatar_payal.png',
        ),
        createdAt: 'vừa xong',
        content: trimmed,
        imageUrls: mediaUrls,
      );
      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: [post, ...state.rootThreads],
          clearError: true,
        ),
      );
      return;
    }

    final post = await _repository.createPost(
      content: content,
      mediaUrls: mediaUrls,
    );
    emit(
      state.copyWith(
        status: HomeFeedStatus.loaded,
        rootThreads: [post, ...state.rootThreads],
        clearError: true,
      ),
    );
  }

  Future<void> togglePostLike(ThreadItemModel post) async {
    if (AppConfig.uiPreviewMode) {
      emit(
        state.copyWith(
          rootThreads: _replaceThread(
            state.rootThreads,
            post.id,
            (thread) => thread.copyWith(
              likesCount: thread.isLikedByMe
                  ? (thread.likesCount > 0 ? thread.likesCount - 1 : 0)
                  : thread.likesCount + 1,
              isLikedByMe: !thread.isLikedByMe,
            ),
          ),
          clearError: true,
        ),
      );
      return;
    }

    final result = post.isLikedByMe
        ? await _repository.unlikePost(post.id)
        : await _repository.likePost(post.id);

    emit(
      state.copyWith(
        rootThreads: _replaceThread(
          state.rootThreads,
          result.targetId,
          (thread) => thread.copyWith(
            likesCount: result.likeCount,
            isLikedByMe: result.isLiked,
          ),
        ),
      ),
    );
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void _handleRealtimeEvent(RealtimeAppEvent event) {
    if (event.type == 'post.created') {
      _handlePostCreated(event.payload);
      return;
    }

    if (event.type != 'user.profile.updated') {
      return;
    }

    final userId = event.payload['userId'] as String?;
    if (userId == null || userId.isEmpty) {
      return;
    }

    final displayName = event.payload['displayName'] as String?;
    final username = event.payload['username'] as String?;
    final avatarUrl = event.payload['avatarUrl'] as String?;

    emit(
      state.copyWith(
        rootThreads: state.rootThreads
            .map(
              (thread) => _patchThreadAuthor(
                thread,
                userId: userId,
                displayName: displayName,
                username: username,
                avatarUrl: avatarUrl,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  void _handlePostCreated(Map<String, dynamic> payload) {
    final postJson = payload['post'];
    final map = postJson is Map<String, dynamic>
        ? postJson
        : (payload['data'] is Map<String, dynamic>
              ? payload['data'] as Map<String, dynamic>
              : payload);
    if (map['id'] is! String) {
      return;
    }

    try {
      final post = ThreadApiMapper.postFromJson(map);
      final alreadyExists = state.rootThreads.any((item) => item.id == post.id);
      if (alreadyExists) {
        return;
      }
      emit(
        state.copyWith(
          rootThreads: [post, ...state.rootThreads],
          lastLoadedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (_) {
      // Ignore malformed realtime payloads and keep current feed state.
    }
  }

  Future<void> syncIfStale({
    Duration maxAge = const Duration(minutes: 2),
  }) async {
    final lastLoadedAt = state.lastLoadedAtEpochMs;
    if (lastLoadedAt == null) {
      await loadHomeFeed();
      return;
    }

    final elapsed = DateTime.now().millisecondsSinceEpoch - lastLoadedAt;
    if (elapsed >= maxAge.inMilliseconds) {
      await loadHomeFeed();
    }
  }

  ThreadItemModel _patchThreadAuthor(
    ThreadItemModel thread, {
    required String userId,
    String? displayName,
    String? username,
    String? avatarUrl,
  }) {
    final nextChildren = thread.children
        .map(
          (child) => _patchThreadAuthor(
            child,
            userId: userId,
            displayName: displayName,
            username: username,
            avatarUrl: avatarUrl,
          ),
        )
        .toList(growable: false);
    final nextPreviews = thread.previewReplies
        .map(
          (child) => _patchThreadAuthor(
            child,
            userId: userId,
            displayName: displayName,
            username: username,
            avatarUrl: avatarUrl,
          ),
        )
        .toList(growable: false);

    if (thread.author.id != userId) {
      return thread.copyWith(children: nextChildren, previewReplies: nextPreviews);
    }

    final nextAuthor = thread.author.copyWith(
      name: displayName ?? thread.author.name,
      username: username ?? thread.author.username,
      avatarUrl: avatarUrl ?? thread.author.avatarUrl,
      avatarAssetPath: avatarUrl != null ? null : thread.author.avatarAssetPath,
    );

    return thread.copyWith(
      author: nextAuthor,
      children: nextChildren,
      previewReplies: nextPreviews,
    );
  }

  List<ThreadItemModel> _replaceThread(
    List<ThreadItemModel> threads,
    String threadId,
    ThreadItemModel Function(ThreadItemModel thread) update,
  ) {
    return threads
        .map((thread) => thread.id == threadId ? update(thread) : thread)
        .toList(growable: false);
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription.cancel();
    return super.close();
  }
}
