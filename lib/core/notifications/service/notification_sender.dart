import 'package:flutter/material.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/data/repo/notification_repo.dart';

/// Call NotificationSender.send() from any feature to send a notification.
/// Always silent-fails — notification errors never break the main flow.
class NotificationSender {
  static NotificationRepo? _repo;

  static void init(NotificationRepo repo) {
    _repo = repo;
  }

  static Future<void> send({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? referenceId,
    String? referenceType,
  }) async {
    try {
      await _repo?.sendNotification(
        userId: userId,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        referenceType: referenceType,
      );
    } catch (e) {
      debugPrint('NotificationSender.send failed: $e');
    }
  }
}
