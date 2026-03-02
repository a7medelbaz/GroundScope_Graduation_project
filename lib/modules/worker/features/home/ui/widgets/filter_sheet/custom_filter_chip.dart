import 'package:flutter/material.dart';
import 'package:ground_scope/core/extensions/context_extensions.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

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
        padding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(16),
          vertical: responsiveHeight(8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary300
              : context.customColors.divider.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(responsiveRadius(20)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary300
                : context.customColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.font14Regular.copyWith(
            color: isSelected
                ? AppColors.grey0
                : context.customColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
