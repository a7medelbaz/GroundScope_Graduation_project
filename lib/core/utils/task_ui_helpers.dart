import 'package:flutter/material.dart';
import '../shared/data/models/task_model.dart';
import '../themes/app_colors.dart';
import 'extensions/context_ext.dart';

class TaskUiHelpers {
  static Color priorityColor(TaskPriority priority) => switch (priority) {
    TaskPriority.critical => AppColors.red200,
    TaskPriority.high => AppColors.secondary200,
    TaskPriority.medium => AppColors.amber200,
    TaskPriority.low => AppColors.green200,
  };

  static Color statusColor(TaskStatus status, BuildContext context) =>
      switch (status) {
        TaskStatus.inProgress => AppColors.primary200,
        TaskStatus.completed => AppColors.green200,
        TaskStatus.pending => AppColors.amber200,
        TaskStatus.assigned => AppColors.blue200,
        TaskStatus.paused => AppColors.secondary200,
        TaskStatus.cancelled => context.customColors.textDisabled,
      };
}
