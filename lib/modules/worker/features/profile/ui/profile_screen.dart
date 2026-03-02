import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/functions/app_setting_method.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            verticalSpacing(50),
            CustomTextButton(
              text: 'Swith Lan ',
              onPressed: () {
                switchLanguage(context);
              },
            ),
            verticalSpacing(50),
            CustomTextButton(
              text: 'Swith Theme ',
              onPressed: () {
                switchTheme(context);
              },
            ),
            verticalSpacing(50),
            CustomTextButton(text: 'Logout', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
