import 'package:t_app/core/network/backend_url_normalizer.dart';

import '../../domain/entities/reel.dart';

class ReelModel extends Reel {
  const ReelModel({
    required super.id,
    required super.videoUrl,
    required super.authorId,
    required super.username,
    required super.displayName,
    required super.caption,
    required super.music,
    required super.avatarUrl,
    required super.likes,
    required super.comments,
    required super.isLiked,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    final author =
        json['author'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return ReelModel(
      id: json['id'] as String,
      videoUrl: BackendUrlNormalizer.normalize(
        json['videoUrl'] as String? ?? '',
      ),
      authorId: author['id'] as String? ?? '',
      username: author['username'] as String? ?? '',
      displayName: author['displayName'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      music: json['audioTitle'] as String? ?? '',
      avatarUrl: BackendUrlNormalizer.normalizeNullable(
        author['avatarUrl'] as String?,
      ),
      likes: json['likeCount'] as int? ?? 0,
      comments: json['commentCount'] as int? ?? 0,
      isLiked: json['isLikedByMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'author': {
        'id': authorId,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
      },
      'username': username,
      'caption': caption,
      'audioTitle': music,
      'likeCount': likes,
      'commentCount': comments,
      'isLikedByMe': isLiked,
    };
  }
}
