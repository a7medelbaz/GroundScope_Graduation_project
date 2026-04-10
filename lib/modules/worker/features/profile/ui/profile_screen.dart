import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/utils/functions/app_setting_method.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextButton(
            text: "LogOut ",
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
          verticalSpacing(50),
          CustomTextButton(
            text: "Switch Language",
            onPressed: () {
              switchLanguage(context);
            },
          ),
          verticalSpacing(50),
          CustomTextButton(
            text: "Switch theme",
            onPressed: () {
              switchTheme(context);
            },
          ),
          const Center(child: Text('Profile Screen')),
        ],
      ),
    );
  }
}
