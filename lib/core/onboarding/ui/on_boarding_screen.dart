import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../router/routes.dart';
import '../../themes/app_text_styles.dart';
import '../../utils/app_assets.dart';
import '../../utils/extensions.dart';
import '../../utils/spacing.dart';
import '../../widgets/custom_text_button.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.appLogoSVG, height: 120.h),
              verticalSpacing(40),
              Text(
                'GroundScope',
                style: AppTextStyles.font30WhiteBold,
                textAlign: TextAlign.center,
              ),
              verticalSpacing(16),
              Text(
                'Organize, supervise, and manage airport ground operations efficiently.',
                style: AppTextStyles.font16WhiteRegular,
                textAlign: TextAlign.center,
              ),
              verticalSpacing(40),
              SizedBox(
                width: double.infinity,
                child: CustomTextButton(
                  buttonText: 'Get Started',
                  onPressed: () {
                    context.pushReplacementNamed(Routes.loginScreen);
                  },
                  textStyle: AppTextStyles.font18WhiteBold,
                  buttonHeight: 52.h,
                  verticalPadding: 12.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
