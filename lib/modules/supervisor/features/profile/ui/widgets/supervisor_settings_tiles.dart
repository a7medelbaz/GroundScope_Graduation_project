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
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'worker_profile.settings.language'.tr(),
            trailing: isArabic ? 'العربية' : 'English',
            showArrow: true,
            onTap: () => switchLanguage(context),
          ),
          _Divider(),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'worker_profile.settings.dark_mode'.tr(),
            trailing:
                isDark ? 'worker_profile.dark'.tr() : 'worker_profile.light'.tr(),
            showArrow: true,
            onTap: () => switchTheme(context),
          ),
          _Divider(),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'worker_profile.about'.tr(),
            showArrow: true,
            onTap: () => AppDialogs.showInfo(
              context,
              title: 'worker_profile.about'.tr(),
              message: 'worker_profile.about_description'.tr(),
            ),
          ),
          _Divider(),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'worker_profile.logout'.tr(),
            titleColor: AppColors.red200,
            iconColor: AppColors.red200,
            showArrow: false,
            onTap: () => AppDialogs.showConfirm(
              context,
              title: 'worker_profile.logout'.tr(),
              message: 'logout_confirm_message'.tr(),
              onConfirm: () => context.read<AuthCubit>().logout(),
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
    required this.title,
    required this.showArrow,
    required this.onTap,
    this.trailing,
    this.titleColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final bool showArrow;
  final VoidCallback onTap;
  final String? trailing;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rr(16)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
        child: Row(
          children: [
            Icon(
              icon,
              size: rf(20),
              color: iconColor ?? AppColors.primary200,
            ),
            horizontalSpacing(12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: titleColor ?? cc.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style:
                    AppTextStyles.font12Light.copyWith(color: cc.textSecondary),
              ),
              horizontalSpacing(4),
            ],
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: rf(12),
                color: cc.textHint,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: context.customColors.divider,
      indent: rw(16),
      endIndent: rw(16),
    );
  }
}
