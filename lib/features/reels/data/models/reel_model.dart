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
    required super.isFollowing,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    final author =
        json['author'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final mediaUrls =
        (json['mediaUrls'] as List?)
            ?.whereType<String>()
            .toList(growable: false) ??
        const <String>[];
    final videoUrl = BackendUrlNormalizer.normalizeVideoPlayback(
      json['videoUrl'] as String? ?? _pickVideoUrl(mediaUrls),
    );

    return ReelModel(
      id: json['id'] as String,
      videoUrl: videoUrl,
      authorId: author['id'] as String? ?? '',
      username: author['username'] as String? ?? '',
      displayName: author['displayName'] as String? ?? '',
      caption: json['caption'] as String? ?? json['content'] as String? ?? '',
      music: json['audioTitle'] as String? ?? '',
      avatarUrl: BackendUrlNormalizer.normalizeNullable(
        author['avatarUrl'] as String?,
      ),
      likes: json['likeCount'] as int? ?? 0,
      comments:
          json['commentCount'] as int? ?? json['replyCount'] as int? ?? 0,
      isLiked: json['isLikedByMe'] as bool? ?? false,
      isFollowing: author['isFollowing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'mediaUrls': [videoUrl],
      'author': {
        'id': authorId,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'isFollowing': isFollowing,
      },
      'username': username,
      'caption': caption,
      'audioTitle': music,
      'likeCount': likes,
      'commentCount': comments,
      'isLikedByMe': isLiked,
    };
  }

  static String _pickVideoUrl(List<String> mediaUrls) {
    for (final url in mediaUrls) {
      if (_looksLikeVideoUrl(url)) {
        return url;
      }
    }

    return mediaUrls.isNotEmpty ? mediaUrls.first : '';
  }

  static bool _looksLikeVideoUrl(String url) {
    final normalized = url.toLowerCase().split('?').first;
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.webm') ||
        normalized.endsWith('.m4v') ||
        normalized.contains('/video/upload/');
  }
}
