import 'package:flutter/material.dart';

enum NotificationFilter { all, tasks, reports }

enum NotificationType { task, report, info }

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final NotificationType type;
  final VoidCallback? onAction;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.onAction,
  });
}

