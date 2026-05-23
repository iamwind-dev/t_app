import 'package:equatable/equatable.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';

import 'user_post_mapper.dart';

class UserPostsPage extends Equatable {
  const UserPostsPage({required this.items, required this.pageInfo});

  factory UserPostsPage.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final pageInfo = json['pageInfo'];

    return UserPostsPage(
      items: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(UserPostMapper.toThreadItem)
                .toList(growable: false)
          : const [],
      pageInfo: pageInfo is Map<String, dynamic>
          ? UserPostsPageInfo.fromJson(pageInfo)
          : const UserPostsPageInfo(nextCursor: null, hasNextPage: false),
    );
  }

  final List<ThreadItemModel> items;
  final UserPostsPageInfo pageInfo;

  @override
  List<Object?> get props => [items, pageInfo];
}

class UserPostsPageInfo extends Equatable {
  const UserPostsPageInfo({
    required this.nextCursor,
    required this.hasNextPage,
  });

  factory UserPostsPageInfo.fromJson(Map<String, dynamic> json) {
    return UserPostsPageInfo(
      nextCursor: json['nextCursor'] as String?,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  final String? nextCursor;
  final bool hasNextPage;

  @override
  List<Object?> get props => [nextCursor, hasNextPage];
}
