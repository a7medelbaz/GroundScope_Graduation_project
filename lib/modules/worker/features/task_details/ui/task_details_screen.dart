import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/custom_text_button.dart';
import '../../home/data/models/task_model.dart';
import 'widgets/quick_report_bottom_sheet.dart';
import 'widgets/task_details_check_list.dart';
import 'widgets/task_details_header.dart';
import 'widgets/task_details_timer.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key, required this.task});
  final TaskModel task;

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return AppColors.primary300;
      case TaskStatus.done:
        return AppColors.green100;
      case TaskStatus.pending:
        return AppColors.grey400;
    }
  }

  void _openQuickReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickReportBottomSheet(task: task),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final statusColor = _statusColor(task.status);

    return Scaffold(
      floatingActionButton: SizedBox(
        width: rw(150),
        child: CustomTextButton(
          text: "Quick Report",
          textStyle: AppTextStyles.font14SemiBold,
          onPressed: () => _openQuickReport(context),
          size: CustomButtonSize.small,
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: rh(12)),
          prefixIcon: const Icon(Icons.add_outlined),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Task Details'),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(20),
                  vertical: rh(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskDetailsHeader(task: task, statusColor: statusColor),
                    verticalSpacing(24),
                    const Text(
                      'Progress',
                      style: AppTextStyles.font16ExtraBold,
                    ),
                    verticalSpacing(10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: task.progress,
                              minHeight: 10,
                              backgroundColor: context.customColors.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),
                        ),
                        horizontalSpacing(12),
                        Text(
                          '${(task.progress * 100).toInt()}%',
                          style: AppTextStyles.font12SemiBold.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),

                    verticalSpacing(24),
                    TaskDetailsTimer(task: task),
                    verticalSpacing(24),
                    TaskDetailsCheckList(statusColor: statusColor),
                    verticalSpacing(32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
