import 'package:flutter/material.dart';
import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/widgets/task_details_action_tile.dart';

class TaskDetailsQuickActionsRow extends StatelessWidget {
  const TaskDetailsQuickActionsRow({
    super.key,
    required this.onInfoTap,
    required this.onReportTap,
    required this.taskStatus,
  });

  final VoidCallback onInfoTap;
  final VoidCallback onReportTap;
  final TaskStatus taskStatus;

  bool get _canReport =>
      taskStatus == TaskStatus.inProgress ||
      taskStatus == TaskStatus.paused ||
      taskStatus == TaskStatus.assigned;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Row(
      children: [
        Expanded(
          child: TaskDetailsActionTile(
            icon: Icons.info_outline_rounded,
            label: 'Task Info',
            sublabel: 'Flight & stand details',
            color: AppColors.primary200,
            onTap: onInfoTap,
          ),
        ),
        horizontalSpacing(12),
        Expanded(
          child: TaskDetailsActionTile(
            icon: Icons.flag_outlined,
            label: 'Quick Report',
            sublabel: _canReport ? 'Report an issue' : 'Task not active',
            color: _canReport ? AppColors.secondary200 : cc.textDisabled,
            onTap: _canReport ? onReportTap : null,
            disabled: !_canReport,
          ),
        ),
      ],
    );
  }
}
