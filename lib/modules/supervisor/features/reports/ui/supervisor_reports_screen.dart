import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/core/widgets/filter_pills.dart';
import 'package:ground_scope/core/widgets/search_with_counter.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';
import '../logic/cubit/supervisor_reports_cubit.dart';
import 'widgets/supervisor_report_card.dart';

class SupervisorReportsScreen extends StatefulWidget {
  const SupervisorReportsScreen({super.key});

  @override
  State<SupervisorReportsScreen> createState() =>
      _SupervisorReportsScreenState();
}

class _SupervisorReportsScreenState extends State<SupervisorReportsScreen> {
  static const _filters = ['all', 'open', 'acknowledged', 'resolved'];

  String get _serviceTypeId {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthSuccess ? (auth.userModel.serviceTypeId ?? '') : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<SupervisorReportsCubit>().loadReports(_serviceTypeId);
  }

  void _onAcknowledge(BuildContext ctx, String reportId) {
    AppDialogs.showConfirm(
      ctx,
      message: 'acknowledge_confirm'.tr(),
      confirmText: 'acknowledge'.tr(),
      onConfirm: () =>
          ctx.read<SupervisorReportsCubit>().acknowledgeReport(reportId),
    );
  }

  void _onResolve(BuildContext ctx, String reportId) {
    AppDialogs.showConfirm(
      ctx,
      message: 'resolve_confirm'.tr(),
      confirmText: 'resolve'.tr(),
      onConfirm: () =>
          ctx.read<SupervisorReportsCubit>().resolveReport(reportId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocListener<SupervisorReportsCubit, SupervisorReportsState>(
      listenWhen: (p, c) => c.error != null && p.error != c.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!.messageKey)),
        );
      },
      child: Scaffold(
        backgroundColor: cc.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
              buildWhen: (p, c) =>
                  p.allReports.length != c.allReports.length,
              builder: (context, state) => _Header(
                totalReports: state.allReports.length,
              ),
            ),
            // Search + counter
            BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
              buildWhen: (p, c) =>
                  p.resultCount != c.resultCount ||
                  p.searchQuery != c.searchQuery,
              builder: (context, state) => SearchWithCounter(
                hintText: 'search_by_flight_or_description'.tr(),
                onChanged:
                    context.read<SupervisorReportsCubit>().setSearch,
                resultCount: state.resultCount,
              ),
            ),
            // Filter pills
            BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
              buildWhen: (p, c) => p.activeFilter != c.activeFilter,
              builder: (context, state) => FilterPills(
                filters: _filters,
                filterLabels: [
                  'filter_all'.tr(),
                  'filter_open'.tr(),
                  'filter_acknowledged'.tr(),
                  'filter_resolved'.tr(),
                ],
                activeFilter: state.activeFilter,
                onFilterChanged:
                    context.read<SupervisorReportsCubit>().setFilter,
              ),
            ),
            // Body
            Expanded(
              child: BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
                builder: (context, state) {
                  if (state.status == SupervisorReportsStatus.loading ||
                      state.status == SupervisorReportsStatus.initial) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary200),
                    );
                  }
                  if (state.status == SupervisorReportsStatus.failure) {
                    return ErrorScreen(
                      error: state.error?.messageKey,
                      onRetry: () => context
                          .read<SupervisorReportsCubit>()
                          .loadReports(_serviceTypeId),
                    );
                  }
                  if (state.filteredReports.isEmpty) {
                    return _EmptyState();
                  }
                  return RefreshIndicator(
                    color: AppColors.primary200,
                    onRefresh: () => context
                        .read<SupervisorReportsCubit>()
                        .refresh(_serviceTypeId),
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          rw(16), rh(8), rw(16), rh(24)),
                      itemCount: state.filteredReports.length,
                      itemBuilder: (ctx, i) {
                        final report = state.filteredReports[i];
                        final isLoading =
                            state.status ==
                                    SupervisorReportsStatus.actionLoading &&
                                state.actionReportId == report.id;
                        return SupervisorReportCard(
                          report: report,
                          isLoading: isLoading,
                          onAcknowledge: () => _onAcknowledge(ctx, report.id),
                          onResolve: () => _onResolve(ctx, report.id),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.totalReports});
  final int totalReports;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        rw(16),
        rh(20) + MediaQuery.of(context).padding.top,
        rw(16),
        rh(16),
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'supervisor_reports_title'.tr(),
            style: AppTextStyles.font18ExtraBold
                .copyWith(color: AppColors.white),
          ),
          verticalSpacing(2),
          Text(
            'from_your_units'.tr(),
            style: AppTextStyles.font12Light.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: rf(64), color: cc.iconSecondary),
            verticalSpacing(16),
            Text(
              'no_results_found'.tr(),
              style: AppTextStyles.font16SemiBold
                  .copyWith(color: cc.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
