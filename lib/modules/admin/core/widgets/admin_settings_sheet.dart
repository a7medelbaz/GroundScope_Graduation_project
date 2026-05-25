import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/settings/cubit/app_settings_cubit.dart';
import 'package:ground_scope/core/settings/cubit/app_settings_state.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/functions/app_setting_method.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/core/widgets/widgets/admin_settings_header.dart';
import 'package:ground_scope/modules/admin/core/widgets/widgets/admin_settings_logout_tile.dart';
import 'package:ground_scope/modules/admin/core/widgets/widgets/admin_settings_section_label.dart';
import 'package:ground_scope/modules/admin/core/widgets/widgets/admin_settings_tile.dart';

void showAdminSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<AppSettingsCubit>(),
      child: BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: const _AdminSettingsSheetContent(),
      ),
    ),
  );
}

class _AdminSettingsSheetContent extends StatelessWidget {
  const _AdminSettingsSheetContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, settings) {
        final authState = context.watch<AuthCubit>().state;
        final String fullName = authState is AuthSuccess
            ? authState.userModel.fullName
            : 'Admin';
        final String email = authState is AuthSuccess
            ? authState.userModel.email
            : '';

        final isArabic = settings.isArabic;
        final isDark = settings.themeMode == ThemeMode.dark ||
            (settings.themeMode == ThemeMode.system && context.isDarkMode);

        return Container(
          decoration: BoxDecoration(
            color: context.customColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(rr(24))),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(rw(20), rh(12), rw(20), rh(32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: rw(40),
                    height: rh(4),
                    decoration: BoxDecoration(
                      color: context.customColors.border,
                      borderRadius: BorderRadius.circular(rr(2)),
                    ),
                  ),
                ),
                verticalSpacing(20),
                AdminSettingsHeader(fullName: fullName, email: email),
                verticalSpacing(24),
                Divider(color: context.customColors.divider),
                verticalSpacing(16),
                AdminSettingsSectionLabel(label: 'preferences'.tr().toUpperCase()),
                verticalSpacing(4),
                AdminSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'language'.tr(),
                  trailing: isArabic ? 'العربية' : 'English',
                  onTap: () => switchLanguage(context),
                ),
                AdminSettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'theme'.tr(),
                  trailing: isDark ? 'dark'.tr() : 'light'.tr(),
                  onTap: () => switchTheme(context),
                ),
                verticalSpacing(8),
                Divider(color: context.customColors.divider),
                verticalSpacing(16),
                AdminSettingsSectionLabel(label: 'about'.tr().toUpperCase()),
                verticalSpacing(4),
                AdminSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'app_version'.tr(),
                  // TODO: replace with PackageInfo.fromPlatform() when package_info_plus is added
                  trailing: '1.0.0',
                ),
                verticalSpacing(8),
                Divider(color: context.customColors.divider),
                verticalSpacing(8),
                const AdminSettingsLogoutTile(),
              ],
            ),
          ),
        );
      },
    );
  }
}
