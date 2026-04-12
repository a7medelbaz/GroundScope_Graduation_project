import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class TaskDetailsActionTile extends StatelessWidget {
  const TaskDetailsActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(rw(14)),
        decoration: BoxDecoration(
          color: disabled ? cc.surface : color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(rr(14)),
          border: Border.all(
            color: disabled
                ? cc.border.withValues(alpha: 0.4)
                : color.withValues(alpha: 0.3),
            width: disabled ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: rw(38),
              height: rw(38),
              decoration: BoxDecoration(
                color: disabled
                    ? cc.surfaceVariant
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(rr(10)),
              ),
              child: Icon(
                icon,
                color: disabled ? cc.textDisabled : color,
                size: rf(18),
              ),
            ),
            horizontalSpacing(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.font14ExtraBold.copyWith(
                      color: disabled ? cc.textDisabled : cc.textPrimary,
                    ),
                  ),
                  verticalSpacing(2),
                  Text(
                    sublabel,
                    style: AppTextStyles.font12Light.copyWith(
                      color: cc.textHint,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: disabled ? cc.textDisabled : color,
              size: rf(18),
            ),
          ],
        ),
      ),
    );
  }
}
