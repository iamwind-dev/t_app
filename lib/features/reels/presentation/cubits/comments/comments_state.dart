
abstract class CommentsState {}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<String> comments;

  CommentsLoaded(this.comments);
}

class CommentsError extends CommentsState {
  final String message;

  CommentsError(this.message);
}