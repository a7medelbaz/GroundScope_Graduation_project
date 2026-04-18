import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Text(
      label,
      style: AppTextStyles.font12SemiBold.copyWith(
        color: customColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }
}
