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
      createdAt: _formatCreatedAt(json['createdAt'] as String?),
      content: json['content'] as String? ?? '',
      imageUrls: _stringList(json['mediaUrls']),
      likesCount: json['reactionCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
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
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<String>().toList(growable: false);
  }

  static String _formatCreatedAt(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) {
      return value;
    }

    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}
