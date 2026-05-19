import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/features/activity/domain/notifications_activity_repository.dart';

import 'notification_page.dart';
import 'notification_record.dart';

class NotificationsRepository implements NotificationsActivityRepository {
  const NotificationsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<NotificationPage> listNotifications({
    String? cursor,
    bool unreadOnly = false,
  }) {
    return _apiClient.get<NotificationPage>(
      '/notifications',
      queryParameters: {
        'limit': 20,
        if (cursor != null) 'cursor': cursor,
        if (unreadOnly) 'unreadOnly': true,
      },
      decode: (value) => NotificationPage.fromJson(_asMap(value)),
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/notifications/unread-count',
      decode: _asMap,
    );

    return response['unreadCount'] as int? ?? 0;
  }

  @override
  Future<NotificationRecord> markAsRead(String notificationId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/notifications/$notificationId/read',
      decode: _asMap,
    );

    return NotificationRecord.fromJson(_readNotification(response));
  }

  @override
  Future<int> markAllAsRead() async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/notifications/read-all',
      decode: _asMap,
    );

    return response['updatedCount'] as int? ?? 0;
  }

  static Map<String, dynamic> _readNotification(Map<String, dynamic> response) {
    final notification = response['notification'];
    if (notification is Map<String, dynamic>) {
      return notification;
    }

    throw const FormatException('Notification response missing notification.');
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }
}
