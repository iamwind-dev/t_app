import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/core/realtime/realtime_event_bus.dart';
import 'package:t_app/core/utils/time_formatter.dart';
import 'package:t_app/features/post_detail/data/mock_thread_repository.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/posts/data/moderated_thread_submission.dart';
import 'package:t_app/features/posts/data/moderation_result.dart';
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
          feedRenderVersion: state.feedRenderVersion + 1,
          lastLoadedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          clearError: true,
          hasMore: false,
          isLoadingMore: false,
          clearCursor: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HomeFeedStatus.loading,
        clearError: true,
        isLoadingMore: false,
        hasMore: true,
        clearCursor: true,
      ),
    );

    try {
      final page = await _repository.getFeed(limit: 10);
      final hydratedThreads = await _hydrateFeedPreviewReplies(page.items);

      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: hydratedThreads,
          feedRenderVersion: state.feedRenderVersion + 1,
          nextCursor: page.pageInfo.nextCursor,
          hasMore: page.pageInfo.hasNextPage,
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

  Future<bool> refreshFeed({bool isFromPostCreation = false}) async {
    if (state.isRefreshing) {
      return false;
    }

    emit(
      state.copyWith(
        isRefreshing: true,
        clearError: true,
      ),
    );

    try {
      if (AppConfig.uiPreviewMode) {
        emit(
          state.copyWith(
            status: HomeFeedStatus.loaded,
            rootThreads: const MockThreadRepository().fetchRootThreads(),
            feedRenderVersion: state.feedRenderVersion + 1,
            lastLoadedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
            clearError: true,
            hasMore: false,
            isLoadingMore: false,
            clearCursor: true,
            isRefreshing: false,
          ),
        );
        return true;
      }

      final page = await _repository.getFeed(limit: 10);
      final hydratedThreads = await _hydrateFeedPreviewReplies(page.items);

      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: hydratedThreads,
          feedRenderVersion: state.feedRenderVersion + 1,
          nextCursor: page.pageInfo.nextCursor,
          hasMore: page.pageInfo.hasNextPage,
          lastLoadedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          clearError: true,
          isRefreshing: false,
        ),
      );
      return true;
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isRefreshing: false,
          errorMessage: isFromPostCreation
              ? 'Đã đăng bài, nhưng chưa thể tải lại bảng tin'
              : error.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isRefreshing: false,
          errorMessage: isFromPostCreation
              ? 'Đã đăng bài, nhưng chưa thể tải lại bảng tin'
              : 'Không thể tải lại bảng tin.',
        ),
      );
      return false;
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> loadMoreHomeFeed() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.status == HomeFeedStatus.loading ||
        AppConfig.uiPreviewMode) {
      return;
    }

    emit(
      state.copyWith(
        isLoadingMore: true,
        clearError: true,
      ),
    );

    try {
      final page = await _repository.getFeed(
        limit: 10,
        cursor: state.nextCursor,
      );
      final hydratedThreads = await _hydrateFeedPreviewReplies(page.items);

      final existingIds = state.rootThreads.map((e) => e.id).toSet();
      final uniqueIncoming = hydratedThreads
          .where((item) => !existingIds.contains(item.id))
          .toList(growable: false);

      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: [
            ...state.rootThreads,
            ...uniqueIncoming,
          ],
          nextCursor: page.pageInfo.nextCursor,
          hasMore: page.pageInfo.hasNextPage,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Không thể tải thêm bài viết.',
        ),
      );
    }
  }

  /// Creates a post and returns moderation so the composer can decide UX first.
  Future<ModeratedThreadSubmission> createPost(
    String content, {
    List<String> mediaUrls = const <String>[],
  }) async {
    if (AppConfig.uiPreviewMode) {
      final trimmed = content.trim();
      if (trimmed.isEmpty) {
        return const ModeratedThreadSubmission();
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
        createdAt: TimeFormatter.formatSocialTime(DateTime.now()),
        content: trimmed,
        imageUrls: mediaUrls,
      );

      return ModeratedThreadSubmission(
        thread: post,
        moderation: const ModerationResult(
          text: '',
          finalLabel: 'clean',
          finalConfidence: 0,
          isWarning: false,
          action: 'ALLOW',
          layers: <ModerationLayerResult>[],
          status: 'APPROVED',
          model: '',
        ),
      );
    }

    return _repository.createPost(
      content: content,
      mediaUrls: mediaUrls,
    );
  }

  /// Inserts an accepted post into the feed after moderation UX completes.
  void insertCreatedPost(ThreadItemModel post) {
    final alreadyExists = state.rootThreads.any((item) => item.id == post.id);
    if (alreadyExists) {
      return;
    }

    emit(
      state.copyWith(
        status: HomeFeedStatus.loaded,
        rootThreads: [
          post,
          ...state.rootThreads,
        ],
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
          rootThreads: [
            post,
            ...state.rootThreads,
          ],
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

  Future<List<ThreadItemModel>> _hydrateFeedPreviewReplies(
    List<ThreadItemModel> threads,
  ) async {
    if (threads.isEmpty) {
      return const <ThreadItemModel>[];
    }

    return Future.wait(threads.map(_hydratePreviewReply));
  }

  Future<ThreadItemModel> _hydratePreviewReply(ThreadItemModel thread) async {
    if (thread.previewReply != null || thread.replyCount <= 0 || !thread.isRootThread) {
      return thread;
    }

    try {
      final replies = await _repository.getPostReplies(thread.id, limit: 1);
      final previewReply = replies.items.isEmpty ? null : replies.items.first;
      if (previewReply == null) {
        return thread;
      }

      return thread.copyWith(previewReplies: [previewReply]);
    } catch (_) {
      return thread;
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
      return thread.copyWith(
        children: nextChildren,
        previewReplies: nextPreviews,
      );
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
