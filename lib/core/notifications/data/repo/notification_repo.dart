import 'package:ground_scope/core/notifications/data/models/notification_model.dart';

abstract class NotificationRepo {
  Future<List<NotificationModel>> fetchMyNotifications();
  Future<int> fetchUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? referenceId,
    String? referenceType,
  });
  Stream<int> watchUnreadCount(String userId);
}
