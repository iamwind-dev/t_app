import '../data/notification_page.dart';
import '../data/notification_record.dart';

abstract interface class NotificationsActivityRepository {
  Future<NotificationPage> listNotifications({
    String? cursor,
    bool unreadOnly = false,
  });

  Future<int> getUnreadCount();

  Future<NotificationRecord> markAsRead(String notificationId);

  Future<int> markAllAsRead();
}
