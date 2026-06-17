import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/themes/custom_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import '../../logic/cubit/dashboard_cubit.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: rw(10),
        mainAxisSpacing: rh(10),
        childAspectRatio: 1.6,
      ),
      children: [
        _StatCard(
          label: 'active_tasks'.tr(),
          value: '${state.activeTaskCount}',
          color: AppColors.primary200,
        ),
        _StatCard(
          label: 'pending_requests'.tr(),
          value: '${state.pendingRequestCount}',
          color: AppColors.amber200,
        ),
        _StatCard(
          label: 'units_available'.tr(),
          value: '${state.availableUnitCount}',
          sub: '/ ${state.totalUnitCount}',
          color: AppColors.green200,
        ),
        _StatCard(
          label: 'open_reports'.tr(),
          value: '${state.openReportCount}',
          color: AppColors.red200,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String? sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final CustomColors cc = context.customColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(14)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.font12Light.copyWith(color: cc.textHint),
          ),
          verticalSpacing(4),
          Text(
            value,
            style: AppTextStyles.font20ExtraBold.copyWith(color: color),
          ),
          if (sub != null)
            Text(
              sub!,
              style: AppTextStyles.font12Light.copyWith(color: cc.textHint),
            ),
        ],
      ),
    );
  }
}
