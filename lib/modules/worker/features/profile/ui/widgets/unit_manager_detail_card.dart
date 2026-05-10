import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UnitManagerDetailCard extends StatelessWidget {
  const UnitManagerDetailCard({super.key, required this.manager});

  final UserModel manager;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rw(20)),
      decoration: BoxDecoration(
        color: AppColors.primary200.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(
          color: AppColors.primary200.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: rr(40),
            backgroundColor: _avatarColor(manager.fullName),
            child: Text(
              _initials(manager.fullName),
              style: TextStyle(
                color: AppColors.white,
                fontSize: rf(22),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          verticalSpacing(14),
          Text(
            manager.fullName,
            style: AppTextStyles.font18SemiBold.copyWith(
              color: cc.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpacing(8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(12),
              vertical: rh(5),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary200.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rr(20)),
            ),
            child: Text(
              'worker_profile.unit_manager'.tr(),
              style: AppTextStyles.font12SemiBold.copyWith(
                color: AppColors.primary300,
              ),
            ),
          ),
          if (manager.phone != null) ...[
            verticalSpacing(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: rf(14),
                  color: cc.textSecondary,
                ),
                horizontalSpacing(6),
                Text(
                  manager.phone!,
                  style: AppTextStyles.font14Light.copyWith(
                    color: cc.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts =
        fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _avatarColor(String name) {
    const palette = [
      AppColors.primary200,
      AppColors.secondary200,
      AppColors.green300,
      AppColors.amber300,
      AppColors.blue300,
      AppColors.grey500,
    ];
    return palette[name.hashCode.abs() % palette.length];
  }
}
