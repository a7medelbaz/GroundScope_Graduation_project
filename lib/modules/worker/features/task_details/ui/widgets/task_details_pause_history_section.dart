import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../../../../../core/shared/data/models/task_pause_model.dart';

class TaskDetailsPauseHistorySection extends StatelessWidget {
  const TaskDetailsPauseHistorySection({super.key, required this.pauses});
  final List<TaskPauseModel> pauses;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: rw(4),
              height: rh(18),
              decoration: BoxDecoration(
                color: AppColors.amber200,
                borderRadius: BorderRadius.circular(rr(2)),
              ),
            ),
            horizontalSpacing(10),
            Text(
              'worker_task_details.pause_history'.tr(),
              style: AppTextStyles.font18ExtraBold.copyWith(
                color: cc.textPrimary,
              ),
            ),
            horizontalSpacing(8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(2)),
              decoration: BoxDecoration(
                color: AppColors.amber200.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(rr(20)),
              ),
              child: Text(
                '${pauses.length}',
                style: AppTextStyles.font12ExtraBold.copyWith(
                  color: AppColors.amber200,
                ),
              ),
            ),
          ],
        ),
        verticalSpacing(12),
        ...pauses.map(
          (p) => Container(
            margin: EdgeInsets.only(bottom: rh(8)),
            padding: EdgeInsets.all(rw(12)),
            decoration: BoxDecoration(
              color: AppColors.amber200.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(rr(12)),
              border: Border.all(
                color: AppColors.amber200.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pause_circle_outline_rounded,
                  color: AppColors.amber200,
                  size: 18,
                ),
                horizontalSpacing(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.reason ?? 'worker_task_details.no_reason'.tr(),
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: cc.textSecondary,
                        ),
                      ),
                      verticalSpacing(3),
                      Text(
                        p.isActive
                            ? 'worker_task_details.currently_paused'.tr()
                            : 'worker_task_details.resumed_after'.tr(
                                namedArgs: {
                                  'minutes': '${p.duration.inMinutes}',
                                },
                              ),
                        style: AppTextStyles.font12Light.copyWith(
                          color: cc.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
