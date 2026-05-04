import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';

class ThreadApiMapper {
  const ThreadApiMapper._();

  static ThreadItemModel postFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return ThreadItemModel(
      id: id,
      rootThreadId: id,
      author: _authorFromJson(json['author']),
      createdAt: _formatCreatedAt(json['createdAt'] as String?),
      content: json['content'] as String? ?? '',
      imageUrls: _stringList(json['mediaUrls']),
      likesCount: json['likeCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
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
      createdAt: _formatCreatedAt(json['createdAt'] as String?),
      content: json['content'] as String? ?? '',
      imageUrls: _stringList(json['mediaUrls']),
      likesCount: json['likeCount'] as int? ?? 0,
      replyCount: json['childReplyCount'] as int? ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    );
  }

  static User _authorFromJson(Object? value) {
    final json = value is Map<String, dynamic>
        ? value
        : const <String, dynamic>{};
    final username = json['username'] as String? ?? '';

    return User(
      id: json['id'] as String? ?? '',
      name: json['displayName'] as String? ?? username,
      username: username,
      avatarUrl: json['avatarUrl'] as String?,
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
