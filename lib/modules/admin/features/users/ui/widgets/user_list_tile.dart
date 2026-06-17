import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/users/logic/cubit/user_reset_cubit.dart';
import 'package:ground_scope/modules/admin/features/users/logic/cubit/users_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/users/ui/widgets/user_role_badge.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    super.key,
    required this.user,
    required this.animationDelay,
    required this.onResetSuccess,
  });

  final UserModel user;
  final Duration animationDelay;
  final VoidCallback onResetSuccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(8)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Opacity(
        opacity: user.isActive ? 1.0 : 0.55,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: rw(16), vertical: rh(12)),
          child: Row(
            children: [
              _Avatar(name: user.fullName, role: user.userRole),
              horizontalSpacing(12),
              Expanded(child: _Content(user: user)),
              _MenuButton(
                user: user,
                onResetSuccess: onResetSuccess,
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.08, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.role});

  final String name;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) {
      return w.isNotEmpty ? w[0].toUpperCase() : '';
    }).join();
    final color = UserRoleBadge.colorFor(role);
    return Container(
      width: rw(44),
      height: rw(44),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.font14SemiBold.copyWith(color: color),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final subtitle = user.serviceTypeName ?? user.unitName ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user.fullName,
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: context.customColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            horizontalSpacing(6),
            UserRoleBadge(role: user.userRole),
          ],
        ),
        if (subtitle.isNotEmpty) ...[
          verticalSpacing(2),
          Text(
            subtitle,
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        verticalSpacing(2),
        Text(
          user.email,
          style: AppTextStyles.font12Light.copyWith(
            color: context.customColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        verticalSpacing(4),
        Row(
          children: [
            Container(
              width: rw(6),
              height: rw(6),
              decoration: BoxDecoration(
                color: user.isActive
                    ? AppColors.green200
                    : AppColors.grey400,
                shape: BoxShape.circle,
              ),
            ),
            horizontalSpacing(4),
            Text(
              user.isActive ? 'activate_user'.tr() : 'deactivate_user'.tr(),
              style: AppTextStyles.font12Light.copyWith(
                color: user.isActive
                    ? AppColors.green200
                    : AppColors.grey400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.user,
    required this.onResetSuccess,
  });

  final UserModel user;
  final VoidCallback onResetSuccess;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert,
          color: context.customColors.textSecondary, size: rw(20)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      onSelected: (value) => _onAction(context, value),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'reset',
          child: Row(
            children: [
              Icon(Icons.lock_reset_outlined,
                  size: rw(16), color: AppColors.primary200),
              horizontalSpacing(8),
              Text('reset_password'.tr(),
                  style: AppTextStyles.font14Light),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                user.isActive
                    ? Icons.block_outlined
                    : Icons.check_circle_outline,
                size: rw(16),
                color: user.isActive
                    ? AppColors.red200
                    : AppColors.green200,
              ),
              horizontalSpacing(8),
              Text(
                user.isActive
                    ? 'deactivate_user'.tr()
                    : 'activate_user'.tr(),
                style: AppTextStyles.font14Light,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onAction(BuildContext context, String action) {
    if (action == 'reset') {
      context.read<UserResetCubit>().resetPassword(user);
    } else if (action == 'toggle') {
      context.read<UsersListCubit>().toggleActive(user);
    }
  }
}
