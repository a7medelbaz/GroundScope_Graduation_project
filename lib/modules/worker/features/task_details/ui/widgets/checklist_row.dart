import 'package:flutter/material.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/models/checklist_item_model.dart';

class ChecklistRow extends StatelessWidget {
  const ChecklistRow({
    super.key,
    required this.item,
    required this.index,
    required this.canCheck,
    required this.onToggle,
  });

  final ChecklistItemModel item;
  final int index;
  final bool canCheck;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final checked = item.isChecked;

    return GestureDetector(
      onTap: canCheck ? onToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
        decoration: BoxDecoration(
          color: checked
              ? AppColors.green200.withValues(alpha: 0.06)
              : cc.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(
            color: checked
                ? AppColors.green200.withValues(alpha: 0.3)
                : cc.border.withValues(alpha: 0.5),
            width: checked ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Order index
            SizedBox(
              width: rw(22),
              child: Text(
                '${index + 1}.',
                style: AppTextStyles.font12SemiBold.copyWith(
                  color: cc.textHint,
                ),
              ),
            ),
            horizontalSpacing(8),
            // Item text
            Expanded(
              child: Text(
                item.item,
                style: AppTextStyles.font14Light.copyWith(
                  color: checked ? cc.textHint : cc.textPrimary,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  decorationColor: cc.textHint,
                ),
              ),
            ),
            horizontalSpacing(12),
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: rw(24),
              height: rw(24),
              decoration: BoxDecoration(
                color: checked ? AppColors.green200 : Colors.transparent,
                borderRadius: BorderRadius.circular(rr(6)),
                border: Border.all(
                  color: checked
                      ? AppColors.green200
                      : canCheck
                      ? cc.border
                      : cc.divider,
                  width: 2,
                ),
              ),
              child: checked
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
