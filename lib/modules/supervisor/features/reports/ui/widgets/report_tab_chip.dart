import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class SupervisorReportTabChip extends StatelessWidget {
  const SupervisorReportTabChip({
    super.key,
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: rh(8)),
          margin: EdgeInsets.only(bottom: rh(8)),
          decoration: BoxDecoration(
            color: active ? AppColors.primary200 : cc.surface,
            borderRadius: BorderRadius.circular(rr(10)),
            border: Border.all(
              color: active ? AppColors.primary200 : cc.border,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Text(
                  '$label${count > 0 ? ' ($count)' : ''}',
                  style: AppTextStyles.font12SemiBold.copyWith(
                    color: active ? AppColors.white : cc.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (badge > 0)
                Positioned(
                  top: -rh(4),
                  right: rw(4),
                  child: Container(
                    width: rw(8),
                    height: rw(8),
                    decoration: const BoxDecoration(
                      color: AppColors.red200,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
