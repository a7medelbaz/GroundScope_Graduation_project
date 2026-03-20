import 'package:flutter/material.dart';

import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';

class WorkerStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const WorkerStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: responsiveHeight(16)),
      decoration: BoxDecoration(
        // Using a dark navy that matches the "Exams" card background
        color: isDark ? AppColors.navy800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(responsiveRadius(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: responsiveHeight(24)),
          verticalSpacing(8),
          Text(
            value,
            style: AppTextStyles.font18Bold.copyWith(
              color: isDark ? AppColors.white : AppColors.grey900,
            ),
          ),
          verticalSpacing(4),
          Text(
            label,
            style: AppTextStyles.font12Regular.copyWith(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
