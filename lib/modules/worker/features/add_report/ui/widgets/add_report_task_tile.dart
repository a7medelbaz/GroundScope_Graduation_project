import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';

class AddReportTaskTile extends StatelessWidget {
  const AddReportTaskTile({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return GestureDetector(
      onTap: () {
        context.read<AddReportCubit>().selectTask(task);
        context.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(rw(14)),
        decoration: BoxDecoration(
          color: customColors.surface,
          borderRadius: BorderRadius.circular(rr(14)),
          border: Border.all(color: customColors.border),
        ),
        child: Row(
          children: [
            // Service Icon Container
            Container(
              width: rw(42),
              height: rh(42),
              decoration: BoxDecoration(
                color: AppColors.primary200.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(rr(10)),
              ),
              child: Center(
                child: Text(
                  task.serviceTypeIcon ?? '🔧',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            horizontalSpacing(12),

            // Task Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.flightNumber ?? task.flightId,
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: customColors.textPrimary,
                    ),
                  ),
                  verticalSpacing(2),
                  Text(
                    '${task.serviceTypeName ?? 'Service'} · Stand ${task.standCode ?? '—'}',
                    style: AppTextStyles.font12Light.copyWith(
                      color: customColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(4)),
              decoration: BoxDecoration(
                color: AppColors.primary200.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(rr(8)),
              ),
              child: Text(
                task.status?.label ?? 'Pending',
                style: AppTextStyles.font12SemiBold.copyWith(
                  color: AppColors.primary200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
