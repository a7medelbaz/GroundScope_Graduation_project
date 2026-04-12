import 'package:flutter/material.dart';
import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../../core/utils/spacing.dart';

class SupervisorAdminNotificationCard extends StatelessWidget {
  const SupervisorAdminNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(
          color: cc.border.withAlpha(40), // uniform border
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        // Inner container with left accent border only
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.red200, width: 4)),
        ),
        padding: EdgeInsets.all(rw(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red200,
                  size: rf(18),
                ),
                horizontalSpacing(8),
                Text(
                  'ADMIN NOTIFICATION',
                  style: AppTextStyles.font12ExtraBold.copyWith(
                    color: AppColors.red200,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(8),
                    vertical: rh(3),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.red200,
                    borderRadius: BorderRadius.circular(rr(6)),
                  ),
                  child: Text(
                    'URGENT',
                    style: AppTextStyles.font12ExtraBold.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),

            verticalSpacing(10),

            Text(
              'New safety report submitted for Stand 4B',
              style: AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
            ),

            verticalSpacing(10),

            // CTA
            InkWell(
              onTap: () {
                // TODO: navigate to report
              },
              child: Row(
                children: [
                  Text(
                    'VIEW REPORT',
                    style: AppTextStyles.font12ExtraBold.copyWith(
                      color: AppColors.red200,
                      letterSpacing: 0.8,
                    ),
                  ),
                  horizontalSpacing(4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.red200,
                    size: rf(16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
