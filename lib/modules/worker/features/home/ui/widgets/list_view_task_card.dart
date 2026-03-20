import 'package:flutter/material.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.isLast = false,
  });

  final TaskModel task;
  final bool isLast;

  Color get _statusColor {
    return switch (task.status) {
      TaskStatus.inProgress => AppColors.primary300,
      TaskStatus.done => AppColors.springGreen,
      TaskStatus.pending => AppColors.yellow100.withValues(
        alpha: 0.8,
      ),
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
            width: responsiveWidth(40),
            child: Column(
              children: [
                Container(
                  width: responsiveWidth(36),
                  height: responsiveHeight(36),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor.withValues(alpha: 0.1),
                    border: Border.all(color: _statusColor, width: 2),
                  ),
                  child: Icon(
                    task.icon,
                    color: _statusColor,
                    size: responsiveFontSize(18),
                  ),
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
              margin: EdgeInsets.only(bottom: responsiveHeight(16)),
              padding: EdgeInsets.all(responsiveWidth(14)),
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
                          style: AppTextStyles.font16Bold,
                        ),
                      ),
                      _StatusBadge(
                        label: _statusLabel,
                        color: _statusColor,
                      ),
                    ],
                  ),
                  verticalSpacing(6),
                  Text(
                    '${task.timeRange} | ${task.location}',
                    style: AppTextStyles.font12Regular.copyWith(
                      color: context.customColors.textSecondary,
                    ),
                  ),
                  if (task.status != TaskStatus.pending) ...[
                    verticalSpacing(10),
                    Text(
                      '${(task.progress * 100).toInt()} %',
                      style: AppTextStyles.font12Regular.copyWith(
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
                        valueColor: AlwaysStoppedAnimation(
                          _statusColor,
                        ),
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
      padding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(10),
        vertical: responsiveHeight(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.font12Regular.copyWith(color: color),
      ),
    );
  }
}
