import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel user;

  String get _initials {
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        rw(16),
        rh(28) + MediaQuery.of(context).padding.top,
        rw(16),
        rh(36),
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar circle
          Container(
            width: rw(72),
            height: rw(72),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(rr(36)),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.4),
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                _initials,
                style: AppTextStyles.font24ExtraBold
                    .copyWith(color: AppColors.white),
              ),
            ),
          ),
          verticalSpacing(10),
          Text(
            user.fullName,
            style:
                AppTextStyles.font18ExtraBold.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          verticalSpacing(2),
          Text(
            'supervisor'.tr(),
            style: AppTextStyles.font12Light.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
