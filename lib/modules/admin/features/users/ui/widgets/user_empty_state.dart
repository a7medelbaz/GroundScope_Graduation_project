import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UserEmptyState extends StatelessWidget {
  const UserEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.manage_accounts_outlined,
            size: rw(64),
            color: AppColors.grey200,
          ),
          verticalSpacing(16),
          Text(
            'no_users_found'.tr(),
            style: AppTextStyles.font16SemiBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
          verticalSpacing(8),
          Text(
            'manage_users'.tr(),
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
