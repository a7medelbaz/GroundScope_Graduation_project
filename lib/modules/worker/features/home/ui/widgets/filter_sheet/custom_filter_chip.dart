import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/spacing.dart';

class CustomFilterChip extends StatelessWidget {
  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(8)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary300
              : context.customColors.divider.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(rr(20)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary300
                : context.customColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.font14Light.copyWith(
            color: isSelected
                ? AppColors.white
                : context.customColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
