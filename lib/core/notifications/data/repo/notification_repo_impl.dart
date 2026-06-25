import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/data/remote/notification_remote_ds.dart';
import 'package:ground_scope/core/notifications/data/repo/notification_repo.dart';

class NotificationRepoImpl implements NotificationRepo {
  NotificationRepoImpl(this._ds);
  final NotificationRemoteDs _ds;

  @override
  Future<List<NotificationModel>> fetchMyNotifications() =>
      _ds.fetchMyNotifications();

  @override
  Future<int> fetchUnreadCount() => _ds.fetchUnreadCount();

  @override
  Future<void> markAsRead(String notificationId) =>
      _ds.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead(String userId) => _ds.markAllAsRead(userId);

  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? referenceId,
    String? referenceType,
  }) =>
      _ds.sendNotification(
        userId: userId,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        referenceType: referenceType,
      );

  @override
  Stream<int> watchUnreadCount(String userId) =>
      _ds.watchUnreadCount(userId);
}
