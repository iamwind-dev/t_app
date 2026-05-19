import 'notification_record.dart';

class NotificationPage {
  const NotificationPage({required this.items, required this.pageInfo});

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final pageInfoJson = json['pageInfo'];

    if (itemsJson is! List || pageInfoJson is! Map<String, dynamic>) {
      throw const FormatException('Trang thông báo không hợp lệ.');
    }

    return NotificationPage(
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(NotificationRecord.fromJson)
          .toList(growable: false),
      pageInfo: NotificationPageInfo.fromJson(pageInfoJson),
    );
  }

  final List<NotificationRecord> items;
  final NotificationPageInfo pageInfo;
}

class NotificationPageInfo {
  const NotificationPageInfo({
    required this.nextCursor,
    required this.hasNextPage,
  });

  factory NotificationPageInfo.fromJson(Map<String, dynamic> json) {
    return NotificationPageInfo(
      nextCursor: json['nextCursor'] as String?,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  final String? nextCursor;
  final bool hasNextPage;
}
