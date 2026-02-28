import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('Worker Report Screen', style: AppTextStyles.font20Bold),
      ),
    );
  }
}
