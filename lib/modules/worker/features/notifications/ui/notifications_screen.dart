import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          'Worker Notifications Screen',
          style: AppTextStyles.font20Bold,
        ),
      ),
    );
  }
}
