import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'widgets/auth_bloc_consumer.dart';



import '../../themes/app_text_styles.dart';
import '../../utils/app_assets.dart';
import '../../utils/spacing.dart';

import 'widgets/custom_text_form_.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                  SvgPicture.asset(
                    AppAssets.appLogoSVG,
                    height: 100.h,
                  ),
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
                  CustomTextFormField(
                    hintText: 'Email',
                    controller: emailController,
                  ),
                  verticalSpacing(16),
                  CustomTextFormField(
                    hintText: 'Password',
                    controller: passwordController,
                    isObscureText: true,
                  ),
                  verticalSpacing(60),
                  AuthBlocConsumer(
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
