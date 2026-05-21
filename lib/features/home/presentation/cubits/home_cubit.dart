import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/core/utils/time_formatter.dart';
import 'package:t_app/features/post_detail/data/mock_thread_repository.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/posts/data/moderated_thread_submission.dart';
import 'package:t_app/features/posts/data/moderation_result.dart';
import 'package:t_app/features/posts/domain/posts_feed_repository.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required PostsFeedRepository repository})
    : _repository = repository,
      super(const HomeState());

  final PostsFeedRepository _repository;

  Future<void> loadHomeFeed() async {
    if (AppConfig.uiPreviewMode) {
      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: const MockThreadRepository().fetchRootThreads(),
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
      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: page.items,
          nextCursor: page.pageInfo.nextCursor,
          hasMore: page.pageInfo.hasNextPage,
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
      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: page.items,
          nextCursor: page.pageInfo.nextCursor,
          hasMore: page.pageInfo.hasNextPage,
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
    if (state.isLoadingMore || !state.hasMore || state.status == HomeFeedStatus.loading || AppConfig.uiPreviewMode) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final page = await _repository.getFeed(limit: 10, cursor: state.nextCursor);
      
      // Chống duplicate theo post.id
      final existingIds = state.rootThreads.map((e) => e.id).toSet();
      final uniqueIncoming = page.items.where((e) => !existingIds.contains(e.id)).toList();

      emit(
        state.copyWith(
          status: HomeFeedStatus.loaded,
          rootThreads: [...state.rootThreads, ...uniqueIncoming],
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

  List<ThreadItemModel> _replaceThread(
    List<ThreadItemModel> threads,
    String threadId,
    ThreadItemModel Function(ThreadItemModel thread) update,
  ) {
    return threads
        .map((thread) => thread.id == threadId ? update(thread) : thread)
        .toList(growable: false);
  }
}
