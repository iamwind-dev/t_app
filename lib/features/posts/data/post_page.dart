import 'package:equatable/equatable.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';

class PostPage extends Equatable {
  const PostPage({required this.items, required this.pageInfo});

  factory PostPage.fromJson(
    Map<String, dynamic> json, {
    required ThreadItemModel Function(Map<String, dynamic> json) itemMapper,
  }) {
    final items = json['items'];
    final pageInfo = json['pageInfo'];

    return PostPage(
      items: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(itemMapper)
                .toList(growable: false)
          : const [],
      pageInfo: pageInfo is Map<String, dynamic>
          ? PostPageInfo.fromJson(pageInfo)
          : const PostPageInfo(nextCursor: null, hasNextPage: false),
    );
  }

  final List<ThreadItemModel> items;
  final PostPageInfo pageInfo;

  @override
  List<Object?> get props => [items, pageInfo];
}

class PostPageInfo extends Equatable {
  const PostPageInfo({required this.nextCursor, required this.hasNextPage});

  factory PostPageInfo.fromJson(Map<String, dynamic> json) {
    return PostPageInfo(
      nextCursor: json['nextCursor'] as String?,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  final String? nextCursor;
  final bool hasNextPage;

  @override
  List<Object?> get props => [nextCursor, hasNextPage];
}
