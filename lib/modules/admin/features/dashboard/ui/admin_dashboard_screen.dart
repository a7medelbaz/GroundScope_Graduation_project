import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/core/widgets/admin_section_header.dart';
import 'package:ground_scope/modules/admin/features/dashboard/logic/cubit/admin_dashboard_cubit.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/widgets/admin_dashboard_app_bar.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/widgets/admin_dashboard_features_grid.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/widgets/admin_dashboard_quick_stats_grid.dart';

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
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(20),
                    vertical: rh(8),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        'todays_overview'.tr(),
                        style: AppTextStyles.font14Light.copyWith(
                          color: context.customColors.textSecondary,
                        ),
                      ),
                      verticalSpacing(12),
                      const AdminDashboardQuickStatsGrid(),
                      verticalSpacing(24),
                      AdminSectionHeader(title: 'management'.tr()),
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
}
