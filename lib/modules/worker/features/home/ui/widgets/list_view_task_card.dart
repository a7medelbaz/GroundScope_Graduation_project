import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.isLast = false});

  final TaskModel task;
  final bool isLast;

  Color get _statusColor {
    return switch (task.status) {
      TaskStatus.inProgress => AppColors.primary300,
      TaskStatus.done => AppColors.green200,
      TaskStatus.pending => AppColors.amber100.withValues(alpha: 0.8),
    };
  }

  String get _statusLabel {
    return switch (task.status) {
      TaskStatus.inProgress => 'In-progress',
      TaskStatus.done => 'Done',
      TaskStatus.pending => 'Pending',
    };
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: rw(40),
            child: Column(
              children: [
                Container(
                  width: rw(36),
                  height: rh(36),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor.withValues(alpha: 0.1),
                    border: Border.all(color: _statusColor, width: 2),
                  ),
                  child: Icon(task.icon, color: _statusColor, size: rf(18)),
                ),
                // if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: _statusColor.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          horizontalSpacing(12),
          // Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: rh(16)),
              padding: EdgeInsets.all(rw(14)),
              decoration: BoxDecoration(
                color: context.customColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: AppTextStyles.font16ExtraBold,
                        ),
                      ),
                      _StatusBadge(label: _statusLabel, color: _statusColor),
                    ],
                  ),
                  verticalSpacing(6),
                  Text(
                    '${task.timeRange} | ${task.location}',
                    style: AppTextStyles.font12Light.copyWith(
                      color: context.customColors.textSecondary,
                    ),
                  ),
                  if (task.status != TaskStatus.pending) ...[
                    verticalSpacing(10),
                    Text(
                      '${(task.progress * 100).toInt()} %',
                      style: AppTextStyles.font12Light.copyWith(
                        color: context.customColors.textSecondary,
                      ),
                    ),
                    verticalSpacing(4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.progress,
                        minHeight: 6,
                        backgroundColor: context.customColors.divider,
                        valueColor: AlwaysStoppedAnimation(_statusColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.font12Light.copyWith(color: color),
      ),
    );
  }
}
