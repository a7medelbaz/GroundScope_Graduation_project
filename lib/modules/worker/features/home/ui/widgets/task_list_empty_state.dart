import 'package:flutter/material.dart';
import '../../../../../../core/data/models/task_model.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';

class TaskListEmptyState extends StatelessWidget {
  const TaskListEmptyState({super.key, this.status});

  final TaskStatus? status;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt_rounded, size: rf(52), color: cc.textDisabled),
          verticalSpacing(12),
          Text(
            status == null
                ? 'No tasks for today'
                : 'No ${status!.label.toLowerCase()} tasks',
            style: AppTextStyles.font16SemiBold.copyWith(
              color: cc.textSecondary,
            ),
          ),
          verticalSpacing(4),
          Text(
            'Check back later or contact your supervisor',
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
