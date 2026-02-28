import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(child: Text('WorkerHome', style: AppTextStyles.font20Bold)),
    );
  }
}
