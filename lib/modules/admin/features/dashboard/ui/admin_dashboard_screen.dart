import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/core/widgets/admin_section_header.dart';
import 'package:ground_scope/modules/admin/features/dashboard/logic/cubit/admin_dashboard_cubit.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/widgets/admin_dashboard_app_bar.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/widgets/admin_dashboard_features_grid.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/widgets/admin_dashboard_quick_stats_grid.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/widgets/admin_dashboard_stats_error.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/widgets/admin_dashboard_stats_shimmer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AdminDashboardAppBar(adminName: state.adminName),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: rw(20)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      verticalSpacing(8),
                      AdminSectionHeader(
                        title: 'todays_overview'.tr(),
                      ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
                      verticalSpacing(12),
                      _buildStatsSection(context, state),
                      verticalSpacing(28),
                      AdminSectionHeader(
                        title: 'management'.tr(),
                        seeAllLabel: null,
                      ).animate(delay: 350.ms).fadeIn(duration: 300.ms),
                      verticalSpacing(12),
                      const AdminDashboardFeaturesGrid(),
                      verticalSpacing(24),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AdminDashboardState state) {
    return switch (state.status) {
      AdminDashboardStatus.initial ||
      AdminDashboardStatus.loading => const AdminDashboardStatsShimmer(),
      AdminDashboardStatus.failure => AdminDashboardStatsError(
        onRetry: () => context.read<AdminDashboardCubit>().load(),
      ),
      AdminDashboardStatus.success => AdminDashboardQuickStatsGrid(
        activeFlights: state.activeFlightsCount,
        pendingTasks: state.pendingTasksCount,
        openReports: state.openReportsCount,
        activeUnits: state.activeUnitsCount,
      ),
    };
  }
}
