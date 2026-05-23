import 'package:t_app/core/utils/time_formatter.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/core/network/backend_url_normalizer.dart';

class UserPostMapper {
  const UserPostMapper._();

  static ThreadItemModel toThreadItem(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final authorJson = json['author'];

    return ThreadItemModel(
      id: id,
      rootThreadId: id,
      author: _authorFromJson(
        authorJson is Map<String, dynamic> ? authorJson : const {},
      ),
      createdAt: TimeFormatter.formatSocialTime(json['createdAt']),
      content: json['content'] as String? ?? '',
      imageUrls: _stringList(json['mediaUrls']),
      likesCount: json['reactionCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
      moderationStatus: json['moderationStatus'] as String? ?? 'approved',
      moderationLabel: json['moderationLabel'] as String? ?? 'clean',
      moderationConfidence: _readDouble(json['moderationConfidence']),
      moderationAction: json['moderationAction'] as String? ?? 'ALLOW',
      moderationIsWarning: json['moderationIsWarning'] as bool? ?? false,
      visibilityLevel: json['visibilityLevel'] as String? ?? 'normal',
    );
  }

  static User _authorFromJson(Map<String, dynamic> json) {
    final username = json['username'] as String? ?? '';

    return User(
      id: json['id'] as String? ?? '',
      name: json['displayName'] as String? ?? username,
      username: username,
      avatarUrl: BackendUrlNormalizer.normalizeNullable(
        json['avatarUrl'] as String?,
      ),
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<String>().toList(growable: false);
  }

  /// Reads moderation confidence values from numeric JSON safely.
  static double _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }
}
