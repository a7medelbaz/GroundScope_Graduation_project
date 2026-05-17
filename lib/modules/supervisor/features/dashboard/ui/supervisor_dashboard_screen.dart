import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/data/models/user_date.dart';
import '../../../../../core/auth/logic/cubit/auth_cubit.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../logic/cubit/supervisor_dashboard_cubit.dart';
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

    return BlocConsumer<SupervisorDashboardCubit, SupervisorDashboardState>(
      listener: (context, state) {
        if (state.status == DashboardStatus.sessionExpired) {
          context.read<AuthCubit>().logout();
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SupervisorAppBar(user: user),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary200,
                onRefresh: () async {
                  context.read<SupervisorDashboardCubit>().refresh();
                  await context
                      .read<SupervisorDashboardCubit>()
                      .stream
                      .firstWhere(
                        (s) => s.status != DashboardStatus.loading,
                      )
                      .timeout(
                        const Duration(seconds: 12),
                        onTimeout: () => state,
                      );
                },
                child: state.status == DashboardStatus.failure &&
                        !state.hasData
                    ? _DashboardErrorBody(
                        message: state.error?.messageKey ?? '',
                        onRetry: () => context
                            .read<SupervisorDashboardCubit>()
                            .loadDashboard(),
                      )
                    : ListView(
                        padding: EdgeInsets.symmetric(horizontal: rw(10)),
                        children: [
                          const SupervisorStatsGrid(),
                          verticalSpacing(20),
                          const SupervisorAdminNotificationCard(),
                          verticalSpacing(20),
                          const SupervisorLiveTaskSummary(),
                          verticalSpacing(20),
                          Text(
                            'supervisor_dashboard.quick_actions'.tr(),
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
      },
    );
  }
}

class _DashboardErrorBody extends StatelessWidget {
  const _DashboardErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return ListView(
      children: [
        SizedBox(height: rh(120)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: rf(56),
                color: cc.textHint,
              ),
              verticalSpacing(16),
              Text(
                message.isNotEmpty ? message : 'errors.unknown'.tr(),
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: cc.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpacing(20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('supervisor_dashboard.retry'.tr()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary200,
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(24),
                    vertical: rh(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
