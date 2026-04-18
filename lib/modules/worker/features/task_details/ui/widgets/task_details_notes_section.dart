import 'package:flutter/material.dart';

import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';

class TaskDetailsNotesSection extends StatelessWidget {
  const TaskDetailsNotesSection({super.key, required this.notes});
  final String notes;

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
                color: AppColors.primary200,
                borderRadius: BorderRadius.circular(rr(2)),
              ),
            ),
            horizontalSpacing(10),
            Text(
              'Notes',
              style: AppTextStyles.font18ExtraBold.copyWith(
                color: cc.textPrimary,
              ),
            ),
          ],
        ),
        verticalSpacing(12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(rw(14)),
          decoration: BoxDecoration(
            color: cc.surface,
            borderRadius: BorderRadius.circular(rr(12)),
            border: Border.all(color: cc.border.withValues(alpha: 0.5)),
          ),
          child: Text(
            notes,
            style: AppTextStyles.font14Light.copyWith(
              color: cc.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
