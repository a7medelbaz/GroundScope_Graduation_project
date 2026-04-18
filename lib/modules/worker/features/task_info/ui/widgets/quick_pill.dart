import 'package:flutter/material.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';

class QuickPill extends StatelessWidget {
  const QuickPill({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(5)),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary50, size: rf(12)),
          horizontalSpacing(5),
          Text(
            label,
            style: AppTextStyles.font12SemiBold.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
