part of 'notification_cubit.dart';

enum NotificationListStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationListStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.error,
  });

  final NotificationListStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final AppError? error;

  List<NotificationModel> get unread =>
      notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get read =>
      notifications.where((n) => n.isRead).toList();

  NotificationState copyWith({
    NotificationListStatus? status,
    List<NotificationModel>? notifications,
    int? unreadCount,
    AppError? error,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, notifications, unreadCount, error];
}
