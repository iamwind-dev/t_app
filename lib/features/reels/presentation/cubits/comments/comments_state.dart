import 'package:equatable/equatable.dart';

import '../../../domain/entities/reel_comment.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  const CommentsLoaded({
    required this.comments,
    this.isSubmitting = false,
  });

  final List<ReelComment> comments;
  final bool isSubmitting;

  CommentsLoaded copyWith({
    List<ReelComment>? comments,
    bool? isSubmitting,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [comments, isSubmitting];
}

class CommentsError extends CommentsState {
  const CommentsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
