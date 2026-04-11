import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(8)),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : context.customColors.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(
            color: isSelected ? color : context.customColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: AppTextStyles.font16ExtraBold.copyWith(
                color: isSelected ? color : context.customColors.textPrimary,
              ),
            ),
            verticalSpacing(2),
            Text(
              label,
              style: AppTextStyles.font12Light.copyWith(
                color: isSelected ? color : context.customColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
