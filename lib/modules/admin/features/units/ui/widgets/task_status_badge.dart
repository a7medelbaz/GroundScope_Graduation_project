import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class TaskStatusBadge extends StatelessWidget {
  const TaskStatusBadge({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }

  static Color _color(TaskStatus status) => switch (status) {
        TaskStatus.pending => AppColors.grey400,
        TaskStatus.assigned => AppColors.blue200,
        TaskStatus.inProgress => AppColors.amber200,
        TaskStatus.paused => AppColors.secondary200,
        TaskStatus.completed => AppColors.green200,
        TaskStatus.cancelled => AppColors.red200,
      };
}
