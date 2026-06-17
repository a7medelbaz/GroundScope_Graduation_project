import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UnitEmptyState extends StatelessWidget {
  const UnitEmptyState({super.key, this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: rw(72),
              height: rw(72),
              decoration: BoxDecoration(
                color: AppColors.green200.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_outlined,
                size: rw(36),
                color: AppColors.green200,
              ),
            ),
            verticalSpacing(16),
            Text(
              'no_units_found'.tr(),
              style: AppTextStyles.font16SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(8),
            Text(
              'add_first_unit'.tr(),
              style: AppTextStyles.font14Light.copyWith(
                color: context.customColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAdd != null) ...[
              verticalSpacing(24),
              ElevatedButton.icon(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green200,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rr(12)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(24),
                    vertical: rh(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  'add_unit'.tr(),
                  style: AppTextStyles.font14SemiBold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
