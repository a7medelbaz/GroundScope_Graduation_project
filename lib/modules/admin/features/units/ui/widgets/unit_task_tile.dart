import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/task_status_badge.dart';

class UnitTaskTile extends StatelessWidget {
  const UnitTaskTile({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);
    return Container(
      margin: EdgeInsets.only(bottom: rh(8)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(12)),
        border: Border.all(color: context.customColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: rw(4),
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(rr(12)),
                  bottomLeft: Radius.circular(rr(12)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(12),
                  vertical: rh(10),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildContent(context)),
                    if (task.status != null)
                      TaskStatusBadge(status: task.status!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final flightNum = task.flightNumber ?? '—';
    final serviceType = task.serviceTypeName ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceType.isNotEmpty
              ? '$flightNum · $serviceType'
              : flightNum,
          style: AppTextStyles.font14SemiBold.copyWith(
            color: context.customColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        verticalSpacing(4),
        Text(
          task.scheduledTimeRange,
          style: AppTextStyles.font12Light.copyWith(
            color: context.customColors.textSecondary,
          ),
        ),
      ],
    );
  }

  static Color _priorityColor(TaskPriority priority) => switch (priority) {
        TaskPriority.low => AppColors.grey400,
        TaskPriority.medium => AppColors.blue200,
        TaskPriority.high => AppColors.amber200,
        TaskPriority.critical => AppColors.red200,
      };
}
