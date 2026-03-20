import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/settings_tile.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/functions/app_setting_method.dart';
import '../../../../../../core/utils/spacing.dart';

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(responsiveWidth(14)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(responsiveRadius(16)),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.grey100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'worker_profile.settings.settings'.tr(),
            style: AppTextStyles.font18SemiBold,
          ),
          _buildLanguageTile(
            context,
            context.locale.languageCode == 'ar'
                ? 'العربية'
                : 'English',
          ),
          _buildThemeTile(context),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String currentLang,
  ) {
    return SettingsTile(
      icon: Icons.language_rounded,
      title: 'worker_profile.settings.language'.tr(),
      subtitle: 'worker_profile.settings.language_subtitle'.tr(),
      onTap: () => _showLanguageDialog(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLang, // Variable used here
            style: AppTextStyles.font14Regular.copyWith(
              color: AppColors.electricBlue,
            ),
          ),
          horizontalSpacing(8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.white24,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.navy800 : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsiveRadius(20)),
        ),
        title: Text(
          'worker_profile.settings.select_language'.tr(),
          style: AppTextStyles.font18SemiBold.copyWith(
            color: isDark ? AppColors.white : AppColors.grey900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  responsiveRadius(15),
                ),
                border: Border.all(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.1)
                      : Colors.black,
                  width: 1,
                ),
              ),
              child: _buildLanguageOption(
                context,
                title: 'English',
                onTap: () {
                  setLanguage(context, 'en'); // Force English
                  Navigator.pop(context);
                },
              ),
            ),
            verticalSpacing(16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  responsiveRadius(15),
                ),
                border: Border.all(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.1)
                      : AppColors.black,
                  width: 1,
                ),
              ),
              child: _buildLanguageOption(
                context,
                title: 'العربية',
                onTap: () {
                  // Ensure this logic specifically sets English
                  setLanguage(context, 'ar');
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    // required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: AppTextStyles.font16SemiBold),
      onTap:
          onTap, // Uses the passed onTap to trigger switch + close dialog
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SettingsTile(
      // Switches icon based on current state
      icon: isDark
          ? Icons.dark_mode_outlined
          : Icons.light_mode_outlined,
      title: 'worker_profile.settings.dark_mode'.tr(),
      subtitle: isDark
          ? 'worker_profile.settings.currently_using_dark_theme'.tr()
          : 'worker_profile.settings.currently_using_light_theme'.tr(),
      // No onTap needed here because the switch handles the interaction
      trailing: Switch.adaptive(
        value: isDark,
        activeThumbColor: AppColors.electricBlue,
        // Ensure the inactive track color looks good in your navy containers
        inactiveTrackColor: isDark
            ? AppColors.white.withValues(alpha: 0.1)
            : AppColors.grey200,
        onChanged: (bool value) {
          switchTheme(context);
        },
      ),
    );
  }
}
