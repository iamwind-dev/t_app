import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/post_detail/data/mock_thread_repository.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
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

  Future<void> createPost(String content) async {
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

    final post = await _repository.createPost(content: content);
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
