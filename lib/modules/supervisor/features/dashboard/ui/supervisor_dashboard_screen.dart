import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/modules/supervisor/core/main_navigation/cubit/supervisor_nav_cubit.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/models/service_request_model.dart';
import '../logic/cubit/assign_unit_cubit.dart';
import '../logic/cubit/dashboard_cubit.dart';
import 'widgets/assign_unit_bottom_sheet.dart';
import 'widgets/service_request_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/supervisor_header.dart';
import 'widgets/unit_status_mini_card.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState
    extends State<SupervisorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  void _openAssignSheet(BuildContext context, ServiceRequestModel request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<AssignUnitCubit>()
          ..loadAvailableUnits(request.serviceTypeId),
        child: AssignUnitBottomSheet(request: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.failure) {
          return ErrorScreen(
            error: state.error?.messageKey,
            onRetry: context.read<DashboardCubit>().loadDashboard,
          );
        }
        if (state.status == DashboardStatus.loading ||
            state.status == DashboardStatus.initial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary200),
          );
        }
        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, DashboardState state) {
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is AuthSuccess ? authState.userModel.fullName : '';

    return RefreshIndicator(
      color: AppColors.primary200,
      onRefresh: context.read<DashboardCubit>().refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SupervisorHeader(
              userName: userName,
              serviceTypeName: state.serviceTypeName,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(rw(16), rh(20), rw(16), rh(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatsRow(state: state),
                  verticalSpacing(24),
                  _SectionHeader(
                    title: 'service_requests_section'.tr(),
                    onViewAll: () =>
                        context.read<SupervisorNavCubit>().changeTab(1),
                  ),
                  verticalSpacing(10),
                  if (state.pendingRequests.isEmpty)
                    const _EmptySection()
                  else
                    ...state.pendingRequests.take(5).map(
                          (r) => ServiceRequestCard(
                            request: r,
                            onAssignTap: () => _openAssignSheet(context, r),
                          ),
                        ),
                  verticalSpacing(24),
                  _SectionHeader(
                    title: 'live_unit_status_section'.tr(),
                    onViewAll: () =>
                        context.read<SupervisorNavCubit>().changeTab(2),
                  ),
                  verticalSpacing(10),
                  if (state.unitsPreview.isEmpty)
                    const _EmptySection()
                  else
                    ...state.unitsPreview.take(3).map(
                          (u) => UnitStatusMiniCard(unit: u),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              AppTextStyles.font14ExtraBold.copyWith(color: cc.textPrimary),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'view_all'.tr(),
              style: AppTextStyles.font12SemiBold
                  .copyWith(color: AppColors.primary200),
            ),
          ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection();

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(16)),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: rf(36), color: cc.iconSecondary),
            verticalSpacing(8),
            Text(
              'no_results_found'.tr(),
              style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
