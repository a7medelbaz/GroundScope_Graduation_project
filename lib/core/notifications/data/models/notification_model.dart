import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';

enum NotificationType {
  taskAssigned,
  alert,
  delay,
  report,
  flightLanded;

  static NotificationType fromString(String value) => switch (value) {
        'task_assigned' => NotificationType.taskAssigned,
        'alert' => NotificationType.alert,
        'delay' => NotificationType.delay,
        'report' => NotificationType.report,
        'flight_landed' => NotificationType.flightLanded,
        _ => NotificationType.alert,
      };

  String get toDbString => switch (this) {
        NotificationType.taskAssigned => 'task_assigned',
        NotificationType.alert => 'alert',
        NotificationType.delay => 'delay',
        NotificationType.report => 'report',
        NotificationType.flightLanded => 'flight_landed',
      };

  String get label => switch (this) {
        NotificationType.taskAssigned => 'Task Assigned',
        NotificationType.alert => 'Alert',
        NotificationType.delay => 'Delay',
        NotificationType.report => 'Report',
        NotificationType.flightLanded => 'Flight Landed',
      };

  /// Localization key for the type label — resolve with `.tr()` in the UI.
  String get labelKey => switch (this) {
        NotificationType.taskAssigned => 'notification_type.task_assigned',
        NotificationType.alert => 'notification_type.alert',
        NotificationType.delay => 'notification_type.delay',
        NotificationType.report => 'notification_type.report',
        NotificationType.flightLanded => 'notification_type.flight_landed',
      };

  IconData get icon => switch (this) {
        NotificationType.taskAssigned => Icons.assignment_rounded,
        NotificationType.alert => Icons.warning_amber_rounded,
        NotificationType.delay => Icons.timer_off_rounded,
        NotificationType.report => Icons.flag_rounded,
        NotificationType.flightLanded => Icons.flight_land_rounded,
      };

  Color get color => switch (this) {
        NotificationType.taskAssigned => AppColors.primary200,
        NotificationType.alert => AppColors.red200,
        NotificationType.delay => AppColors.amber200,
        NotificationType.report => AppColors.secondary200,
        NotificationType.flightLanded => AppColors.green200,
      };
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final bool sentViaFcm;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    required this.sentViaFcm,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      type: NotificationType.fromString(map['type']?.toString() ?? ''),
      referenceId: map['reference_id']?.toString(),
      referenceType: map['reference_type']?.toString(),
      isRead: map['is_read'] as bool? ?? false,
      sentViaFcm: map['sent_via_fcm'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
      referenceType: referenceType,
      isRead: isRead ?? this.isRead,
      sentViaFcm: sentViaFcm,
      createdAt: createdAt,
    );
  }
}
