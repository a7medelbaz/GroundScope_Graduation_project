import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(12)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: rw(24),
                color: iconColor ?? context.customColors.iconPrimary,
              ),
              Text(
                '$count',
                style: AppTextStyles.font22ExtraBold.copyWith(
                  color: context.customColors.textPrimary,
                ),
              ),
            ],
          ),
          verticalSpacing(8),
          Text(
            label,
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
