import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminSettingsTile extends StatelessWidget {
  const AdminSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rr(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rh(12)),
        child: Row(
          children: [
            Container(
              width: rw(36),
              height: rw(36),
              decoration: BoxDecoration(
                color: context.customColors.surfaceVariant,
                borderRadius: BorderRadius.circular(rr(10)),
              ),
              child: Icon(
                icon,
                size: rw(18),
                color: context.customColors.iconPrimary,
              ),
            ),
            horizontalSpacing(12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: context.customColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: AppTextStyles.font14Light.copyWith(
                  color: context.customColors.textSecondary,
                ),
              ),
              horizontalSpacing(4),
              Icon(
                Icons.chevron_right,
                size: rw(18),
                color: context.customColors.iconSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
