import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/widgets/task_selector_sheet.dart';

class TaskSelectorTile extends StatelessWidget {
  const TaskSelectorTile({
    super.key,
    this.preSelectedTask,
    required this.tasks,
  });

  final TaskModel? preSelectedTask;
  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final state = context.watch<AddReportCubit>().state;
    final isLocked = preSelectedTask != null;

    return GestureDetector(
      onTap: isLocked ? null : () => _openTaskSheet(context, tasks: tasks),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
        decoration: BoxDecoration(
          color: state.hasTask
              ? customColors.surface.withValues(alpha: 0.12)
              : customColors.surfaceVariant,
          borderRadius: BorderRadius.circular(rr(16)),
          border: Border.all(
            color: state.hasTask
                ? AppColors.primary200.withValues(alpha: 0.6)
                : customColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: state.hasTask
                    ? AppColors.primary200.withValues(alpha: .15)
                    : customColors.surfaceVariant,
                borderRadius: BorderRadius.circular(rr(10)),
              ),
              child: Icon(
                Icons.flight_rounded,
                size: 20,
                color: state.hasTask
                    ? AppColors.primary200
                    : customColors.iconSecondary,
              ),
            ),
            horizontalSpacing(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.hasTask
                        ? 'worker_add_report.linked_task'.tr()
                        : 'worker_add_report.select_task'.tr(),
                    style: AppTextStyles.font12Light.copyWith(
                      color: customColors.textSecondary,
                    ),
                  ),
                  verticalSpacing(2),
                  Text(
                    state.selectedTaskLabel ??
                        'worker_add_report.tap_to_choose_task'.tr(),
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: state.hasTask
                          ? customColors.textPrimary
                          : customColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: customColors.iconSecondary,
              )
            else if (state.hasTask)
              GestureDetector(
                onTap: () => context.read<AddReportCubit>().clearTask(),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: customColors.iconSecondary,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: customColors.iconSecondary,
              ),
          ],
        ),
      ),
    );
  }

  void _openTaskSheet(BuildContext context, {required List<TaskModel> tasks}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AddReportCubit>(),
        child: const TaskSelectorSheet(),
      ),
    );
  }
}
