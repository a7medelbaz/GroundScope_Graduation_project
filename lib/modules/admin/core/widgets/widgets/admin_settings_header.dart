import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminSettingsHeader extends StatelessWidget {
  const AdminSettingsHeader({
    super.key,
    required this.fullName,
    required this.email,
  });

  final String fullName;
  final String email;

  static const List<Color> _avatarPalette = [
    AppColors.primary200,
    AppColors.blue200,
    AppColors.green200,
    AppColors.amber300,
    AppColors.secondary200,
    AppColors.primary300,
  ];

  Color _avatarColor() {
    final hash = fullName.codeUnits.fold(0, (a, b) => a + b);
    return _avatarPalette[hash % _avatarPalette.length];
  }

  String _initials() {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColor();
    return Row(
      children: [
        CircleAvatar(
          radius: rw(24),
          backgroundColor: avatarColor,
          child: Text(
            _initials(),
            style: AppTextStyles.font16SemiBold.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        horizontalSpacing(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: AppTextStyles.font16SemiBold.copyWith(
                  color: context.customColors.textPrimary,
                ),
              ),
              verticalSpacing(2),
              Text(
                email,
                style: AppTextStyles.font12Light.copyWith(
                  color: context.customColors.textSecondary,
                ),
              ),
              verticalSpacing(4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(8),
                  vertical: rh(3),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(rr(8)),
                  border: Border.all(color: AppColors.primary100),
                ),
                child: Text(
                  'administrator'.tr(),
                  style: AppTextStyles.font12SemiBold.copyWith(
                    color: AppColors.primary300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
