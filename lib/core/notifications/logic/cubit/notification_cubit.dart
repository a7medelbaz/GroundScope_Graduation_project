import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/data/repo/notification_repo.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repo) : super(const NotificationState());

  final NotificationRepo _repo;
  StreamSubscription<int>? _unreadSubscription;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationListStatus.loading));
    try {
      final notifications = await _repo.fetchMyNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(state.copyWith(
        status: NotificationListStatus.success,
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } on AppError catch (e) {
      emit(state.copyWith(
        status: NotificationListStatus.failure,
        error: e,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: NotificationListStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repo.markAsRead(notificationId);

      final updated = state.notifications
          .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
          .toList();

      emit(state.copyWith(
        notifications: updated,
        unreadCount: updated.where((n) => !n.isRead).length,
      ));
    } catch (_) {}
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _repo.markAllAsRead(userId);

      final updated = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      emit(state.copyWith(
        notifications: updated,
        unreadCount: 0,
      ));
    } catch (_) {}
  }

  void startUnreadWatch(String userId) {
    _unreadSubscription?.cancel();
    _unreadSubscription = _repo.watchUnreadCount(userId).listen(
      (count) => emit(state.copyWith(unreadCount: count)),
      onError: (_) {},
    );
  }

  @override
  Future<void> close() {
    _unreadSubscription?.cancel();
    return super.close();
  }
}
