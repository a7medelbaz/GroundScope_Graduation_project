import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/core/widgets/admin_stat_card.dart';

class AdminDashboardQuickStatsGrid extends StatelessWidget {
  const AdminDashboardQuickStatsGrid({
    super.key,
    required this.activeFlights,
    required this.pendingTasks,
    required this.openReports,
    required this.activeUnits,
    required this.flightsNeedingAttention,
  });

  final int activeFlights;
  final int pendingTasks;
  final int openReports;
  final int activeUnits;
  final int flightsNeedingAttention;

  @override
  Widget build(BuildContext context) {
    final stats = [
      AdminStatCardData(
        label: 'active_flights'.tr(),
        count: activeFlights,
        icon: Icons.flight_outlined,
        iconColor: AppColors.blue200,
      ),
      AdminStatCardData(
        label: 'pending_tasks'.tr(),
        count: pendingTasks,
        icon: Icons.assignment_outlined,
        iconColor: AppColors.amber200,
      ),
      AdminStatCardData(
        label: 'open_reports'.tr(),
        count: openReports,
        icon: Icons.report_outlined,
        iconColor: AppColors.red200,
      ),
      AdminStatCardData(
        label: 'active_units'.tr(),
        count: activeUnits,
        icon: Icons.local_shipping_outlined,
        iconColor: AppColors.green200,
      ),
      AdminStatCardData(
        label: 'flights_needing_attention'.tr(),
        count: flightsNeedingAttention,
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.amber200,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: rw(12),
        mainAxisSpacing: rh(12),
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return AdminStatCard(data: stats[index])
            .animate(delay: Duration(milliseconds: 150 + index * 50))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
      },
    );
  }
}
