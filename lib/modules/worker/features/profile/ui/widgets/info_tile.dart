import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart'
    show AppTextStyles;

import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/utils/spacing.dart';

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool hasCopy;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.hasCopy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsiveHeight(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Icon with subtle background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.electricBlue,
              size: 20,
            ),
          ),
          horizontalSpacing(16),
          // 2. Labels and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.font12Regular),
                verticalSpacing(4),
                Text(value, style: AppTextStyles.font16SemiBold),
              ],
            ),
          ),
          // 3. Optional Copy Icon
          if (hasCopy)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(
                Icons.copy_all_rounded,
                size: 18,
                color: AppColors.white24,
              ),
            ),
        ],
      ),
    );
  }
}
