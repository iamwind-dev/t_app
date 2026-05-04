import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/posts/domain/posts_feed_repository.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required PostsFeedRepository repository})
    : _repository = repository,
      super(const HomeState());

  final PostsFeedRepository _repository;

  Future<void> loadHomeFeed() async {
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
          errorMessage: 'Unable to load feed.',
        ),
      );
    }
  }

  Future<void> createPost(String content) async {
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
