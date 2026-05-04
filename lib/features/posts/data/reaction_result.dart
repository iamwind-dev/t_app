import 'package:equatable/equatable.dart';

class ReactionResult extends Equatable {
  const ReactionResult({
    required this.targetId,
    required this.likeCount,
    required this.isLiked,
  });

  factory ReactionResult.fromPostJson(Map<String, dynamic> json) {
    return ReactionResult(
      targetId: json['postId'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  factory ReactionResult.fromReplyJson(Map<String, dynamic> json) {
    return ReactionResult(
      targetId: json['replyId'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  final String targetId;
  final int likeCount;
  final bool isLiked;

  @override
  List<Object?> get props => [targetId, likeCount, isLiked];
}
