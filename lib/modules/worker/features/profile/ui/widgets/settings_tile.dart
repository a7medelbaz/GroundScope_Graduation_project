import 'package:flutter/material.dart';

import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsiveRadius(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: responsiveHeight(12),
          horizontal: responsiveWidth(4),
        ),
        child: Row(
          children: [
            // 1. Settings Icon with subtle background
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
            // 2. Title and optional Subtitle
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
                  if (subtitle != null) ...[
                    verticalSpacing(2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.font12Regular.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 3. Trailing widget (usually an arrow or a switch)
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.white24
                      : AppColors.grey300,
                ),
          ],
        ),
      ),
    );
  }
}
