import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../../home/data/models/task_model.dart';

class TaskDetailsHeader extends StatelessWidget {
  const TaskDetailsHeader({
    super.key,
    required this.task,
    required this.statusColor,
  });
  final TaskModel task;
  final Color statusColor;

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(32)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.15),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(task.icon, color: statusColor, size: rf(24)),
          ),
          horizontalSpacing(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTextStyles.font16ExtraBold),
                verticalSpacing(4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: rf(14),
                      color: context.customColors.textSecondary,
                    ),
                    horizontalSpacing(4),
                    Text(
                      task.location,
                      style: AppTextStyles.font12Light.copyWith(
                        color: context.customColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                verticalSpacing(4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: rf(14),
                      color: context.customColors.textSecondary,
                    ),
                    horizontalSpacing(4),
                    Text(
                      task.timeRange,
                      style: AppTextStyles.font12Light.copyWith(
                        color: context.customColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: rw(32)),
            padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(6)),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(task.status),
              style: AppTextStyles.font12SemiBold.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
