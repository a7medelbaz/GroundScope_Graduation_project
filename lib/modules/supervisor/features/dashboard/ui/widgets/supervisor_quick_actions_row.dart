import 'package:flutter/material.dart';

import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/spacing.dart';

class SupervisorQuickActionsRow extends StatelessWidget {
  const SupervisorQuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionButton(
          icon: Icons.warning_amber_rounded,
          label: 'Report Incident',
          backgroundColor: AppColors.primary200,
          onTap: () {
            // TODO: navigate to report incident screen
          },
        ),
        verticalSpacing(12),
        _QuickActionButton(
          icon: Icons.assignment_outlined,
          label: 'Assign Task',
          backgroundColor: AppColors.grey700,
          onTap: () {
            // TODO: navigate to assign task screen
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(16)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(rr(14)),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: rw(36),
              height: rw(36),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(rr(10)),
              ),
              child: Icon(icon, color: AppColors.white, size: rf(18)),
            ),
            horizontalSpacing(14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.font16SemiBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.white.withValues(alpha: 0.7),
              size: rf(20),
            ),
          ],
        ),
      ),
    );
  }
}