import 'package:t_app/core/utils/time_formatter.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/core/network/backend_url_normalizer.dart';

class ThreadApiMapper {
  const ThreadApiMapper._();

  static ThreadItemModel postFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return ThreadItemModel(
      id: id,
      rootThreadId: id,
      author: _authorFromJson(json['author']),
      createdAt: TimeFormatter.formatSocialTime(json['createdAt']),
      content: json['content'] as String? ?? '',
      imageUrls: _stringList(json['mediaUrls']),
      likesCount: json['likeCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
      moderationStatus: json['moderationStatus'] as String? ?? 'approved',
      moderationLabel: json['moderationLabel'] as String? ?? 'clean',
      moderationConfidence: _readDouble(json['moderationConfidence']),
      moderationAction: json['moderationAction'] as String? ?? 'ALLOW',
      moderationIsWarning: json['moderationIsWarning'] as bool? ?? false,
      visibilityLevel: json['visibilityLevel'] as String? ?? 'normal',
    );
  }

  static ThreadItemModel replyFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final postId = json['postId'] as String? ?? id;

    return ThreadItemModel(
      id: id,
      parentId: json['parentReplyId'] as String?,
      rootThreadId: postId,
      author: _authorFromJson(json['author']),
      createdAt: TimeFormatter.formatSocialTime(json['createdAt']),
      content: json['content'] as String? ?? '',
      imageUrls: _stringList(json['mediaUrls']),
      likesCount: json['likeCount'] as int? ?? 0,
      replyCount: json['childReplyCount'] as int? ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
      moderationStatus: json['moderationStatus'] as String? ?? 'approved',
      moderationLabel: json['moderationLabel'] as String? ?? 'clean',
      moderationConfidence: _readDouble(json['moderationConfidence']),
      moderationAction: json['moderationAction'] as String? ?? 'ALLOW',
      moderationIsWarning: json['moderationIsWarning'] as bool? ?? false,
      visibilityLevel: json['visibilityLevel'] as String? ?? 'normal',
    );
  }

  static User _authorFromJson(Object? value) {
    final json = value is Map<String, dynamic>
        ? value
        : const <String, dynamic>{};

    final username = json['username'] as String? ?? '';
    final rawAvatarUrl =
        json['avatarUrl'] ?? json['avatar_url'] ?? json['avatar'];

    return User(
      id: json['id'] as String? ?? '',
      name: json['displayName'] as String? ?? username,
      username: username,
      avatarUrl: BackendUrlNormalizer.normalizeNullable(
        rawAvatarUrl as String?,
      ),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<String>()
        .map(BackendUrlNormalizer.normalize)
        .toList(growable: false);
  }

  /// Reads moderation confidence values from numeric JSON safely.
  static double _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }
}