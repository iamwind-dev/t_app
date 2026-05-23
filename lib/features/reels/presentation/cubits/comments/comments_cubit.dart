import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/reels/domain/repositories/reels_repository.dart';
import 'package:t_app/features/reels/presentation/cubits/comments/comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit({
    required ReelsRepository repository,
    required String reelId,
    void Function()? onCommentCreated,
  })  : _repository = repository,
        _reelId = reelId,
        _onCommentCreated = onCommentCreated,
        super(const CommentsInitial());

  final ReelsRepository _repository;
  final String _reelId;
  final void Function()? _onCommentCreated;

  Future<void> loadComments() async {
    emit(const CommentsLoading());

    try {
      final comments = await _repository.getComments(_reelId);
      emit(CommentsLoaded(comments: comments));
    } catch (_) {
      emit(const CommentsError('Cannot load comments.'));
    }
  }

  Future<void> addComment(String text) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true));

    try {
      final comment = await _repository.createComment(
        reelId: _reelId,
        content: text.trim(),
      );
      emit(
        CommentsLoaded(
          comments: [...currentState.comments, comment],
          isSubmitting: false,
        ),
      );
      _onCommentCreated?.call();
    } catch (_) {
      emit(currentState.copyWith(isSubmitting: false));
    }
  }
}
