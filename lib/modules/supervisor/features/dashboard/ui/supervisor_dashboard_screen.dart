import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/auth/data/models/user_date.dart';
import '../../../../../core/auth/logic/cubit/auth_cubit.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import 'widgets/supervisor_admin_notification_card.dart';
import 'widgets/supervisor_app_bar.dart';
import 'widgets/supervisor_live_task_summary.dart';
import 'widgets/supervisor_quick_actions_row.dart';
import 'widgets/supervisor_status_grid.dart';

class SupervisorDashboardScreen extends StatelessWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          return _DashboardBody(user: authState.userModel);
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SupervisorAppBar(user: user),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary200,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: rw(10),
                // vertical: rh(5),
              ),
              children: [
                const SupervisorStatsGrid(),
                verticalSpacing(20),
                const SupervisorAdminNotificationCard(),
                verticalSpacing(20),
                const SupervisorLiveTaskSummary(),
                verticalSpacing(20),
                Text(
                  'Quick Actions',
                  style: AppTextStyles.font18SemiBold.copyWith(
                    color: cc.textPrimary,
                  ),
                ),
                verticalSpacing(12),
                const SupervisorQuickActionsRow(),
                verticalSpacing(24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
