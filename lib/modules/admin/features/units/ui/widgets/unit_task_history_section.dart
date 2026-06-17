import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_task_tile.dart';

class UnitTaskHistorySection extends StatelessWidget {
  const UnitTaskHistorySection({
    super.key,
    required this.activeTasks,
    required this.recentTasks,
  });

  final List<TaskModel> activeTasks;
  final List<TaskModel> recentTasks;

  @override
  Widget build(BuildContext context) {
    final isEmpty = activeTasks.isEmpty && recentTasks.isEmpty;

    if (isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: rh(16)),
        child: Center(
          child: Text(
            'no_tasks_for_unit'.tr(),
            style: AppTextStyles.font14Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeTasks.isNotEmpty) ...[
          _sectionHeader(
            context,
            'active_tasks'.tr(),
            activeTasks.length,
          ),
          verticalSpacing(8),
          ...activeTasks.map((t) => UnitTaskTile(task: t)),
          verticalSpacing(8),
        ],
        if (recentTasks.isNotEmpty) ...[
          _sectionHeader(
            context,
            'recent_tasks'.tr(),
            recentTasks.length,
          ),
          verticalSpacing(8),
          ...recentTasks.map((t) => UnitTaskTile(task: t)),
        ],
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.font14SemiBold.copyWith(
            color: context.customColors.textPrimary,
          ),
        ),
        horizontalSpacing(6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(2)),
          decoration: BoxDecoration(
            color: context.customColors.border,
            borderRadius: BorderRadius.circular(rr(20)),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.font12SemiBold.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
