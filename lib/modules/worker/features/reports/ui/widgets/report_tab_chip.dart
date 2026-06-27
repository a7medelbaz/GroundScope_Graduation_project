import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ReportTabChip extends StatelessWidget {
  const ReportTabChip({
    super.key,
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: rh(10)),
          decoration: BoxDecoration(
            color: active ? AppColors.primary200 : cc.surface,
            borderRadius: BorderRadius.circular(rr(12)),
            border: Border.all(
              color: active ? AppColors.primary200 : cc.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: active ? AppColors.white : cc.textSecondary,
                ),
              ),
              if (count > 0) ...[
                horizontalSpacing(6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(6),
                    vertical: rh(2),
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.white.withValues(alpha: 0.25)
                        : AppColors.primary200.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rr(8)),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.font12SemiBold.copyWith(
                      color: active ? AppColors.white : AppColors.primary200,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
