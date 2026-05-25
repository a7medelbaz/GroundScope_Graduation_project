import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminStatCardData {
  const AdminStatCardData({
    required this.icon,
    required this.count,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color iconColor;
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({super.key, required this.data});

  final AdminStatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(36),
            height: rw(36),
            decoration: BoxDecoration(
              color: data.iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: rw(18), color: data.iconColor),
          ),
          verticalSpacing(16),
          Text(
            '${data.count}',
            style: AppTextStyles.font20ExtraBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
          verticalSpacing(2),
          Text(
            data.label,
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
