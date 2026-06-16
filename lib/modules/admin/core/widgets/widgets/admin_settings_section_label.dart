import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminSettingsSectionLabel extends StatelessWidget {
  const AdminSettingsSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(4)),
      child: Text(
        label,
        style: AppTextStyles.font12SemiBold.copyWith(
          color: context.customColors.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
