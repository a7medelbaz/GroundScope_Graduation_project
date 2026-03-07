import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../extensions/context_extensions.dart';
import '../../router/routes.dart';
import '../../themes/app_text_styles.dart';
import '../../utils/spacing.dart';
import '../../widgets/custom_text_button.dart';
import 'widgets/on_boarding_hero_image.dart';
import 'widgets/on_boarding_top_bar.dart';
import 'widgets/on_boarding_top_logo.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveWidth(16),
            ),
            child: Column(
              children: [
                const OnBoardingTopBar(),
                verticalSpacing(8),
                const Center(child: OnBoardingTopLogo()),
                verticalSpacing(24),
                const OnBoardingHeroImage(),
                verticalSpacing(32),
                Text(
                  "onBoarding.hero_desc".tr(),
                  style: AppTextStyles.font14Regular.copyWith(
                    color: context.customColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpacing(16),
                SizedBox(
                  width: responsiveWidth(320),
                  child: CustomTextButton(
                    borderRadius: responsiveRadius(16),
                    text: "onBoarding.get_started_button".tr(),
                    textStyle: AppTextStyles.font18SemiBold,
                    style: CustomButtonStyle.filled,
                    size: CustomButtonSize.large,
                    onPressed: () =>
                        context.pushNamed(Routes.loginScreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
