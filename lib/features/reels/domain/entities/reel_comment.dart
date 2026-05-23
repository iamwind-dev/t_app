import 'package:equatable/equatable.dart';

class ReelComment extends Equatable {
  const ReelComment({
    required this.id,
    required this.reelId,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.content,
    required this.likeCount,
    required this.isLikedByMe,
    required this.createdAt,
  });

  final String id;
  final String reelId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String content;
  final int likeCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        reelId,
        username,
        displayName,
        avatarUrl,
        content,
        likeCount,
        isLikedByMe,
        createdAt,
      ];
}
