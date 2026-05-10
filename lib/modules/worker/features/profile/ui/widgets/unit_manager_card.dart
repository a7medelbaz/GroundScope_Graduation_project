import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UnitManagerCard extends StatelessWidget {
  const UnitManagerCard({super.key, required this.manager});

  final UserModel manager;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final initials = _initials(manager.fullName);
    final avatarColor = _avatarColor(manager.fullName);

    return Container(
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: AppColors.primary200.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(rr(14)),
        border: Border.all(
          color: AppColors.primary200.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: rr(26),
            backgroundColor: avatarColor,
            child: Text(
              initials,
              style: TextStyle(
                color: AppColors.white,
                fontSize: rf(14),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manager.fullName,
                  style: AppTextStyles.font14SemiBold.copyWith(
                    color: cc.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (manager.phone != null) ...[
                  verticalSpacing(2),
                  Text(
                    manager.phone!,
                    style: AppTextStyles.font12Light.copyWith(
                      color: cc.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(8),
              vertical: rh(4),
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
