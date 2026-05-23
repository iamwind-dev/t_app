import 'package:t_app/core/network/backend_url_normalizer.dart';

import '../../domain/entities/reel_comment.dart';

class ReelCommentModel extends ReelComment {
  const ReelCommentModel({
    required super.id,
    required super.reelId,
    required super.username,
    required super.displayName,
    required super.avatarUrl,
    required super.content,
    required super.likeCount,
    required super.isLikedByMe,
    required super.createdAt,
  });

  factory ReelCommentModel.fromJson(Map<String, dynamic> json) {
    final author =
        json['author'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return ReelCommentModel(
      id: json['id'] as String,
      reelId: json['reelId'] as String? ?? json['postId'] as String? ?? '',
      username: author['username'] as String? ?? '',
      displayName: author['displayName'] as String? ?? '',
      avatarUrl: BackendUrlNormalizer.normalizeNullable(
        author['avatarUrl'] as String?,
      ),
      content: json['content'] as String? ?? '',
      likeCount: json['likeCount'] as int? ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
