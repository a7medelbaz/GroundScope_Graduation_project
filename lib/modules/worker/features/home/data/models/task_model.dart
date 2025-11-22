import 'package:flutter/material.dart';

class Task {
  final String title;
  final String statusLabel;
  final TaskStatus status;
  final String timeRange;
  final String aircraftInfo;
  final int? progress;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const Task({
    required this.title,
    required this.statusLabel,
    required this.status,
    required this.timeRange,
    required this.aircraftInfo,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });
}

enum TaskStatus { inProgress, done, pending }

extension TaskStatusExtension on TaskStatus {
  Color get chipColor {
    switch (this) {
      case TaskStatus.inProgress:
        return const Color(0xFF4F4415); // In-progress badge #4F4415
      case TaskStatus.done:
        return const Color(0xFF28814D); // Done badge #28814D
      case TaskStatus.pending:
        return const Color(0xFF373E48); // Pending badge #373E48
    }
  }

  Color get progressColor {
    switch (this) {
      case TaskStatus.inProgress:
        return const Color(0xFF1585F4); // Blue #1585F4
      case TaskStatus.done:
        return const Color(0xFF22C55E); // Green #22C55E
      case TaskStatus.pending:
        return const Color(0xFF1580EB); // Blue #1580EB (matches icon color)
    }
  }
}

