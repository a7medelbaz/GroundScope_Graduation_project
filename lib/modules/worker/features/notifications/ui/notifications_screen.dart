import 'package:flutter/material.dart';

import '../../../../../core/themes/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Worker Notifications Screen',
          style: AppTextStyles.font20ExtraBold,
        ),
      ),
    );
  }
}
