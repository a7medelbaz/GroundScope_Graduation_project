import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/modules/admin/features/service_types/data/models/service_type_usage_model.dart';

class ServiceTypeUsageSection extends StatelessWidget {
  const ServiceTypeUsageSection({
    super.key,
    required this.model,
    required this.usage,
  });

  final ServiceTypeModel model;
  final ServiceTypeUsageModel usage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(rw(20), rh(24), rw(20), rh(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: rw(40),
              height: rh(4),
              decoration: BoxDecoration(
                color: context.customColors.border,
                borderRadius: BorderRadius.circular(rr(2)),
              ),
            ),
          ),
          verticalSpacing(20),
          Text(
            'usage'.tr(),
            style: AppTextStyles.font18ExtraBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
          verticalSpacing(4),
          Text(
            model.name,
            style: AppTextStyles.font14Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          verticalSpacing(20),
          _UsageRow(
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.primary200,
            label: 'units_using'.tr(),
            count: usage.unitsCount,
          ),
          verticalSpacing(12),
          _UsageRow(
            icon: Icons.assignment_outlined,
            iconColor: Colors.orange,
            label: 'active_tasks_using'.tr(),
            count: usage.activeTasksCount,
          ),
          if (usage.isInUse) ...[
            verticalSpacing(16),
            Container(
              padding: EdgeInsets.all(rw(12)),
              decoration: BoxDecoration(
                color: AppColors.amber0,
                borderRadius: BorderRadius.circular(rr(8)),
                border: Border.all(color: AppColors.amber200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.amber200,
                    size: rw(18),
                  ),
                  horizontalSpacing(8),
                  Expanded(
                    child: Text(
                      'service_type_in_use_message'.tr(),
                      style: AppTextStyles.font12Light.copyWith(
                        color: AppColors.amber200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: rw(20), color: iconColor),
        horizontalSpacing(12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.font14Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
        ),
        Text(
          '$count',
          style: AppTextStyles.font16ExtraBold.copyWith(
            color: context.customColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
