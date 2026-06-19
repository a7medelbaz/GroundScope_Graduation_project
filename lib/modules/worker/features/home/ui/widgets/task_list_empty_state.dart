import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/shared/data/models/task_model.dart';
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
                ? 'worker_home.no_tasks_today'.tr()
                : 'worker_home.no_status_tasks'
                    .tr(namedArgs: {'status': status!.label.toLowerCase()}),
            style: AppTextStyles.font16SemiBold.copyWith(
              color: cc.textSecondary,
            ),
          ),
          verticalSpacing(4),
          Text(
            'worker_home.check_back_later'.tr(),
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
