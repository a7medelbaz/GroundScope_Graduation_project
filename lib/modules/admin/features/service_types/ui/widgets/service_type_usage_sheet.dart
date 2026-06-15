import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/modules/admin/features/service_types/data/models/service_type_usage_model.dart';

void showServiceTypeUsageSheet({
  required BuildContext context,
  required ServiceTypeModel model,
  required Future<ServiceTypeUsageModel> usageFuture,
  required VoidCallback onEdit,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ServiceTypeUsageSheet(
      model: model,
      usageFuture: usageFuture,
      onEdit: onEdit,
    ),
  );
}

class _ServiceTypeUsageSheet extends StatelessWidget {
  const _ServiceTypeUsageSheet({
    required this.model,
    required this.usageFuture,
    required this.onEdit,
  });

  final ServiceTypeModel model;
  final Future<ServiceTypeUsageModel> usageFuture;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(24))),
      ),
      padding: EdgeInsets.fromLTRB(rw(20), rh(12), rw(20), rh(32)),
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
          _SheetHeader(model: model),
          verticalSpacing(20),
          Divider(color: context.customColors.divider),
          verticalSpacing(16),
          Text(
            'currently_used_by'.tr(),
            style: AppTextStyles.font14SemiBold.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          verticalSpacing(12),
          FutureBuilder<ServiceTypeUsageModel>(
            future: usageFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: [
                    _LoadingUsageCard(),
                    verticalSpacing(8),
                    _LoadingUsageCard(),
                  ],
                );
              }
              final usage = snapshot.data!;
              return Column(
                children: [
                  _UsageCard(
                    icon: Icons.local_shipping_outlined,
                    iconColor: AppColors.primary200,
                    count: usage.unitsCount,
                    label: 'units_using'.tr(),
                    subtitle: 'using_this_service_type'.tr(),
                  ),
                  verticalSpacing(8),
                  _UsageCard(
                    icon: Icons.assignment_outlined,
                    iconColor: AppColors.amber200,
                    count: usage.activeTasksCount,
                    label: 'active_tasks_using'.tr(),
                    subtitle: 'in_progress_or_pending'.tr(),
                  ),
                ],
              );
            },
          ),
          verticalSpacing(24),
          Divider(color: context.customColors.divider),
          verticalSpacing(16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    onEdit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary200,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: rh(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rr(14)),
                    ),
                  ),
                  child: Text('edit'.tr(), style: AppTextStyles.font14SemiBold),
                ),
              ),
              horizontalSpacing(12),
              Expanded(
                child: OutlinedButton(
                  onPressed: context.pop,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: rh(14)),
                    side: BorderSide(color: context.customColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rr(14)),
                    ),
                  ),
                  child: Text(
                    'close'.tr(),
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: context.customColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.model});

  final ServiceTypeModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: rw(48),
          height: rw(48),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(rr(12)),
          ),
          child: model.icon != null && model.icon!.isNotEmpty
              ? Center(
                  child: Text(
                    model.icon!,
                    style: TextStyle(fontSize: rf(24)),
                  ),
                )
              : Icon(
                  Icons.build_circle_outlined,
                  size: rw(24),
                  color: AppColors.primary200,
                ),
        ),
        horizontalSpacing(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.name,
              style: AppTextStyles.font18SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
            ),
            verticalSpacing(2),
            Text(
              '${model.defaultDurationMinutes} min',
              style: AppTextStyles.font12Light.copyWith(
                color: context.customColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: context.customColors.background,
        borderRadius: BorderRadius.circular(rr(14)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: rw(40),
            height: rw(40),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rr(10)),
            ),
            child: Icon(icon, size: rw(20), color: iconColor),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.font14SemiBold.copyWith(
                    color: context.customColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.font12Light.copyWith(
                    color: context.customColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: AppTextStyles.font22ExtraBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingUsageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: rh(72),
      decoration: BoxDecoration(
        color: context.customColors.surfaceVariant,
        borderRadius: BorderRadius.circular(rr(14)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
