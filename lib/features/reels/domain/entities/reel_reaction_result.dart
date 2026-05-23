import 'package:equatable/equatable.dart';

class ReelReactionResult extends Equatable {
  const ReelReactionResult({
    required this.reelId,
    required this.likeCount,
    required this.isLiked,
  });

  final String reelId;
  final int likeCount;
  final bool isLiked;

  @override
  List<Object?> get props => [reelId, likeCount, isLiked];
}
