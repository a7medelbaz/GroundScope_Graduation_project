import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ServiceTypeEmptyState extends StatelessWidget {
  const ServiceTypeEmptyState({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(rw(24)),
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build_circle_outlined,
                size: rf(64),
                color: AppColors.primary200,
              ),
            ),
            verticalSpacing(24),
            Text(
              'no_service_types_found'.tr(),
              style: AppTextStyles.font18SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(8),
            Text(
              'add_first_service_type'.tr(),
              style: AppTextStyles.font14Light.copyWith(
                color: context.customColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text('add_service_type'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary200,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: rw(24),
                  vertical: rh(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rr(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
