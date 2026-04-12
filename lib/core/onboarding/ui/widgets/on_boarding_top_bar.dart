import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/functions/app_setting_method.dart';
import '../../../utils/extensions/context_ext.dart';
import '../../../widgets/custom_icon_button.dart';

class OnBoardingTopBar extends StatelessWidget {
  const OnBoardingTopBar({super.key});

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          CustomIconButton(
            backgroundColor: context.customColors.divider.withValues(
              alpha: 0.5,
            ),
            icon: context.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            onPressed: () => switchTheme(context),
          ),
          CustomIconButton(
            backgroundColor: context.customColors.divider.withValues(
              alpha: 0.5,
            ),
            icon: Icons.language_rounded,
            onPressed: () => switchLanguage(context),
            label: context.locale.languageCode.toUpperCase(),
          ),
        ],
      ),
    );
  }
}
