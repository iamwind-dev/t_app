import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/reels/presentation/cubits/comments/comments_state.dart';
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit() : super(CommentsInitial());

  final List<String> _comments = [];

  Future<void> loadComments() async {
    emit(CommentsLoading());

    await Future.delayed(Duration(seconds: 1));

    emit(CommentsLoaded(_comments));
  }

  void addComment(String text) {
    _comments.insert(0, text);

    emit(CommentsLoaded(List.from(_comments)));
  }
}