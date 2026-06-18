import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/themes/custom_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import '../../logic/cubit/dashboard_cubit.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.state, required this.onCardTap});

  final DashboardState state;

  /// Index matches card order: 0=activeTasks, 1=pendingRequests,
  /// 2=unitsAvailable, 3=openReports.
  final List<VoidCallback> onCardTap;

  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: rw(10),
        mainAxisSpacing: rh(10),
        childAspectRatio: 1.45,
      ),
      children: [
        _StatCard(
          label: 'active_tasks'.tr(),
          value: '${state.activeTaskCount}',
          color: AppColors.primary200,
          icon: Icons.check_box_outlined,
          onTap: onCardTap[0],
        ),
        _StatCard(
          label: 'pending_requests'.tr(),
          value: '${state.pendingRequestCount}',
          color: AppColors.amber200,
          icon: Icons.pending_actions_outlined,
          onTap: onCardTap[1],
        ),
        _StatCard(
          label: 'units_available'.tr(),
          value: '${state.availableUnitCount}',
          sub: '/ ${state.totalUnitCount}',
          color: AppColors.green200,
          icon: Icons.local_shipping_outlined,
          onTap: onCardTap[2],
        ),
        _StatCard(
          label: 'open_reports'.tr(),
          value: '${state.openReportCount}',
          color: AppColors.red200,
          icon: Icons.flag_outlined,
          onTap: onCardTap[3],
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
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final String? sub;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CustomColors cc = context.customColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.font12Light.copyWith(color: cc.textHint),
                ),
                Container(
                  width: rw(32),
                  height: rw(32),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(rr(8)),
                  ),
                  child: Icon(icon, color: color, size: rf(18)),
                ),
              ],
            ),
            verticalSpacing(6),
            Text(
              value,
              style: AppTextStyles.font22ExtraBold.copyWith(color: color),
            ),
            if (sub != null)
              Text(
                sub!,
                style: AppTextStyles.font12Light.copyWith(color: cc.textHint),
              ),
          ],
        ),
      ),
    );
  }
}
