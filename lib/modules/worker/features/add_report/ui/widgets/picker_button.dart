import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class PickerButton extends StatelessWidget {
  const PickerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rh(18)),
        decoration: BoxDecoration(
          color: customColors.surfaceVariant,
          borderRadius: BorderRadius.circular(rr(14)),
          border: Border.all(color: customColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: AppColors.primary200),
            verticalSpacing(6),
            Text(
              label,
              style: AppTextStyles.font14SemiBold.copyWith(
                color: customColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
