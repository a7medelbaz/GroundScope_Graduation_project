import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/functions/app_setting_method.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';

class SupervisorSettingsTiles extends StatelessWidget {
  const SupervisorSettingsTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final isArabic = context.isArabic;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16)),
      child: Column(
        children: [
          // Group 1 — preferences
          Container(
            decoration: BoxDecoration(
              color: cc.surface,
              borderRadius: BorderRadius.circular(rr(12)),
              border: Border.all(color: cc.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.language_outlined,
                  label: 'language',
                  trailingText: isArabic ? 'العربية' : 'english'.tr(),
                  showTrailing: true,
                  onTap: () => switchLanguage(context),
                ),
                Divider(height: 1, color: cc.divider),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'dark_mode',
                  showTrailing: false,
                  onTap: () => switchTheme(context),
                ),
                Divider(height: 1, color: cc.divider),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'notifications',
                  showTrailing: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
          verticalSpacing(12),
          // Group 2 — logout
          Container(
            decoration: BoxDecoration(
              color: cc.surface,
              borderRadius: BorderRadius.circular(rr(12)),
              border: Border.all(color: cc.border.withValues(alpha: 0.5)),
            ),
            child: _SettingsTile(
              icon: Icons.logout_outlined,
              label: 'logout',
              showTrailing: false,
              isDestructive: true,
              onTap: () async {
                await AppDialogs.showConfirm(
                  context,
                  message: 'logout_confirm_message'.tr(),
                  onConfirm: () {
                    context.read<AuthCubit>().logout();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.showTrailing,
    required this.onTap,
    this.trailingText,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool showTrailing;
  final String? trailingText;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final iconColor =
        isDestructive ? AppColors.red200 : cc.iconSecondary;
    final labelColor =
        isDestructive ? AppColors.red200 : cc.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
        child: Row(
          children: [
            Icon(icon, size: rf(18), color: iconColor),
            horizontalSpacing(10),
            Expanded(
              child: Text(
                label.tr(),
                style:
                    AppTextStyles.font14Light.copyWith(color: labelColor),
              ),
            ),
            if (showTrailing) ...[
              Text(
                trailingText ?? '',
                style: AppTextStyles.font12Light
                    .copyWith(color: cc.textHint),
              ),
              horizontalSpacing(4),
              Icon(Icons.chevron_right,
                  size: rf(16), color: cc.iconSecondary),
            ],
          ],
        ),
      ),
    );
  }
}
