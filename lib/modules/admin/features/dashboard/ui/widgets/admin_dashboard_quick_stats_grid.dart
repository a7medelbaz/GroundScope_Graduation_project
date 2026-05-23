import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/core/widgets/admin_stat_card.dart';

class AdminDashboardQuickStatsGrid extends StatelessWidget {
  const AdminDashboardQuickStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: rw(12),
      mainAxisSpacing: rh(12),
      childAspectRatio: 1.5,
      children: [
        AdminStatCard(
          icon: Icons.flight_outlined,
          count: 0, // TODO: wire real data
          label: 'active_flights'.tr(),
          iconColor: Colors.blue,
        ),
        AdminStatCard(
          icon: Icons.assignment_outlined,
          count: 0, // TODO: wire real data
          label: 'pending_tasks'.tr(),
          iconColor: Colors.orange,
        ),
        AdminStatCard(
          icon: Icons.report_outlined,
          count: 0, // TODO: wire real data
          label: 'open_reports'.tr(),
          iconColor: Colors.red,
        ),
        AdminStatCard(
          icon: Icons.local_shipping_outlined,
          count: 0, // TODO: wire real data
          label: 'active_units'.tr(),
          iconColor: Colors.green,
        ),
      ],
    );
  }
}
