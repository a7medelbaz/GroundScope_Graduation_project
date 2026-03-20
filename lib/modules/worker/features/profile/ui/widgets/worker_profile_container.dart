import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class WorkerProfileContainer extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String workerId;
  final String unit;
  final String shift;
  final VoidCallback onTap;

  const WorkerProfileContainer({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.workerId,
    required this.unit,
    required this.shift,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Detect current theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsiveWidth(20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.blue, AppColors.blue] // Dark Theme: Navy
                : [
                    AppColors.white70,
                    AppColors.white24,
                  ], // Light Theme: White to Gray
          ),
          borderRadius: BorderRadius.circular(responsiveRadius(24)),
          border: Border.all(
            color: isDark ? AppColors.white05 : AppColors.grayColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.blue800.withValues(alpha: 0.5)
                  : AppColors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Profile Section
            CircleAvatar(
              radius: responsiveRadius(60),
              backgroundColor: isDark
                  ? AppColors.white24
                  : AppColors.grey200,
              backgroundImage: AssetImage(imageUrl),
            ),
            verticalSpacing(12),
            Text(
              name,
              style: AppTextStyles.font20Bold.copyWith(
                color: isDark ? AppColors.white : AppColors.grey900,
              ),
            ),
            verticalSpacing(4),
            Text(
              '${'worker_profile.id'.tr()}: $workerId',
              style: AppTextStyles.font14Regular.copyWith(
                color: isDark ? AppColors.white70 : AppColors.grey500,
              ),
            ),
            verticalSpacing(20),
            Divider(
              color: isDark ? AppColors.white24 : AppColors.grey200,
              thickness: 1,
            ),
            verticalSpacing(15),

            // 2. Info Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  'worker_profile.unit'.tr(),
                  unit,
                  Icons.engineering_outlined,
                  isDark,
                ),
                _buildInfoItem(
                  'worker_profile.shift'.tr(),
                  shift,
                  Icons.access_time_rounded,
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    // Determine dynamic colors for the sub-items
    final Color labelColor = isDark
        ? AppColors.white60
        : AppColors.grey400;
    final Color valueColor = isDark
        ? AppColors.white
        : AppColors.grey800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: labelColor, size: responsiveHeight(16)),
            horizontalSpacing(6),
            Text(
              label,
              style: AppTextStyles.font12SemiBold.copyWith(
                color: labelColor,
              ),
            ),
          ],
        ),
        verticalSpacing(4),
        Text(
          value,
          style: AppTextStyles.font16SemiBold.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
