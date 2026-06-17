import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UserRoleBadge extends StatelessWidget {
  const UserRoleBadge({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final color = _color(role);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
      ),
      child: Text(
        role.label,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }

  static Color _color(UserRole role) => switch (role) {
        UserRole.supervisor => AppColors.primary200,
        UserRole.unitManager => AppColors.amber200,
        UserRole.admin => AppColors.grey400,
      };

  static Color colorFor(UserRole role) => _color(role);
}
