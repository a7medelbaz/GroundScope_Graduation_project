import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import '../logic/cubit/reports_cubit.dart';
import 'widgets/report_card.dart';
import 'widgets/reports_empty_state.dart';
import 'widgets/reports_filter_strip.dart';
import 'widgets/reports_app_bar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      top: false,
      child: Column(
        children: [
          ReportsAppBar(),
          ReportsFilterStrip(),
          Expanded(child: _Body()),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state.status == ReportsStatus.initial ||
            state.status == ReportsStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary200),
          );
        }

        if (state.status == ReportsStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: rf(48),
                  color: context.customColors.textDisabled,
                ),
                verticalSpacing(12),
                Text(
                  state.error?.messageKey ?? 'something_went_wrong'.tr(),
                  style: AppTextStyles.font14Light.copyWith(
                    color: context.customColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpacing(8),
                TextButton.icon(
                  onPressed: () =>
                      context.read<ReportsCubit>().fetchMyReports(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }

        final reports = state.filteredReports;

        if (reports.isEmpty) {
          return ReportsEmptyState(isFiltered: state.selectedFilter != null);
        }

        return RefreshIndicator(
          color: AppColors.primary200,
          backgroundColor: context.customColors.background,
          onRefresh: () => context.read<ReportsCubit>().fetchMyReports(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(rw(20), rh(12), rw(20), rh(24)),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => context.pushNamed(
                Routes.reportsDetailsScreen,
                arguments: {
                  'report': reports[i],
                  'cubit': context.read<ReportsCubit>(),
                },
                rootNavigator: true,
              ),
              child: ReportCard(report: reports[i]),
            ),
          ),
        );
      },
    );
  }
}
