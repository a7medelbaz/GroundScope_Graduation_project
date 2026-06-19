import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import 'task_details_action_tile.dart';

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
            label: 'task_info'.tr(),
            sublabel: 'worker_task_details.flight_stand_details'.tr(),
            color: AppColors.primary200,
            onTap: onInfoTap,
          ),
        ),
        horizontalSpacing(12),
        Expanded(
          child: TaskDetailsActionTile(
            icon: Icons.flag_outlined,
            label: 'worker_task_details.quick_report'.tr(),
            sublabel: _canReport
                ? 'worker_task_details.report_issue'.tr()
                : 'worker_task_details.task_not_active'.tr(),
            color: _canReport ? AppColors.secondary200 : cc.textDisabled,
            onTap: _canReport ? onReportTap : null,
            disabled: !_canReport,
          ),
        ),
      ],
    );
  }
}
