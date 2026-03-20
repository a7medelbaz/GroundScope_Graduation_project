import 'package:flutter/material.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';

class ShiftTaskTile extends StatelessWidget {
  final String title;
  final String time;
  final bool isFirst;
  final bool isLast;

  const ShiftTaskTile({
    super.key,
    required this.title,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : responsiveHeight(12),
      ),
      padding: EdgeInsets.all(responsiveWidth(16)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(responsiveRadius(16)),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.grey100,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Timeline Accent Decor
          Container(
            width: 4,
            height: responsiveHeight(40),
            decoration: BoxDecoration(
              color: AppColors.electricBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          horizontalSpacing(16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.font16SemiBold.copyWith(
                    color: isDark
                        ? AppColors.white
                        : AppColors.grey900,
                  ),
                ),
                verticalSpacing(4),
                Text(
                  time,
                  style: AppTextStyles.font14Regular.copyWith(
                    color: isDark
                        ? AppColors.grey400
                        : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          // Modern "Clock" icon for time-sensitive tasks
          Icon(
            Icons.schedule_rounded,
            color: isDark ? AppColors.white24 : AppColors.grey300,
            size: 20,
          ),
        ],
      ),
    );
  }
}
