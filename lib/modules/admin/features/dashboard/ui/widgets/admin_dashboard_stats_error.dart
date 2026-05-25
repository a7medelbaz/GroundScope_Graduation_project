import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminDashboardStatsError extends StatelessWidget {
  const AdminDashboardStatsError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_outlined,
            size: rw(16),
            color: context.customColors.textSecondary,
          ),
          horizontalSpacing(6),
          Text(
            'could_not_load_stats'.tr(),
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          horizontalSpacing(4),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: rw(8),
                vertical: rh(4),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primary200,
            ),
            child: Text(
              'retry'.tr(),
              style: AppTextStyles.font12SemiBold.copyWith(
                color: AppColors.primary200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
