import 'package:flutter/material.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/service/notification_service.dart';
import 'package:ground_scope/core/router/routes.dart';

class NotificationNavigator {
  static Future<void> handleInitialMessage(BuildContext context) async {
    final message = await NotificationService.instance.getInitialMessage();
    if (message != null && context.mounted) {
      _navigate(context, message.data);
    }
  }

  static void listenForTaps(BuildContext context) {
    NotificationService.instance.onMessageOpenedApp.listen((message) {
      if (context.mounted) _navigate(context, message.data);
    });
  }

  /// Called when tapping a notification tile inside the app.
  static void navigateToReference(
      BuildContext context, NotificationModel notification) {
    _navigateByType(
      context,
      type: notification.type.toDbString,
      referenceId: notification.referenceId,
      referenceType: notification.referenceType,
    );
  }

  static void _navigate(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final referenceId = data['reference_id'] as String?;
    final referenceType = data['reference_type'] as String?;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      _navigateByType(
        context,
        type: type,
        referenceId: referenceId,
        referenceType: referenceType,
      );
    });
  }

  static void _navigateByType(
    BuildContext context, {
    required String type,
    String? referenceId,
    String? referenceType,
  }) {
    if (!context.mounted) return;
    switch (type) {
      case 'task_assigned':
        if (referenceType == 'task' && referenceId != null) {
          Navigator.of(context).pushNamed(
            Routes.taskDetailsScreen,
            arguments: {'taskId': referenceId},
          );
        }
        break;

      case 'flight_landed':
        if (referenceId != null) {
          Navigator.of(context).pushNamed(
            Routes.adminFlightDetailScreen,
            arguments: {'flightId': referenceId},
          );
        }
        break;

      default:
        break;
    }
  }
}
