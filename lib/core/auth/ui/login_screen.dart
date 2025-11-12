import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../themes/app_text_styles.dart';
import '../../utils/app_assets.dart';
import '../../utils/spacing.dart';
import '../../widgets/custom_text_button.dart';
import 'widgets/custom_text_form_.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppAssets.appLogoSVG, height: 100.h),
                  verticalSpacing(16),
                  Text(
                    'GroundScope',
                    style: AppTextStyles.font30WhiteBold,
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacing(8),
                  Text(
                    'Intelligent Ground Operations.',
                    style: AppTextStyles.font16greyRegular,
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacing(95),
                  const CustomTextFormField(hintText: 'Email'),
                  verticalSpacing(16),
                  const CustomTextFormField(
                    hintText: 'Password',
                    isObscureText: true,
                  ),
                  verticalSpacing(60),
                  CustomTextButton(buttonText: 'Login', onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
