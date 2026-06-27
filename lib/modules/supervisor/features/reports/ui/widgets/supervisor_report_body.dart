import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart';
import 'package:ground_scope/modules/supervisor/features/reports/ui/widgets/supervisor_report_card.dart';
import 'package:ground_scope/modules/supervisor/features/reports/ui/widgets/supervisor_report_shimmer_list.dart';

class SupervisorReportBody extends StatelessWidget {
  const SupervisorReportBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
      builder: (context, state) {
        if (state.status == SupervisorReportsStatus.initial ||
            state.status == SupervisorReportsStatus.loading) {
          return const SupervisorReportShimmerList();
        }

        if (state.status == SupervisorReportsStatus.failure) {
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
                ),
                verticalSpacing(8),
                TextButton.icon(
                  onPressed: () =>
                      context.read<SupervisorReportsCubit>().load(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }

        final reports = state.filteredList;

        if (reports.isEmpty) {
          return Center(
            child: Text(
              'reports.empty.no_sent'.tr(),
              style: AppTextStyles.font14Light.copyWith(
                color: context.customColors.textHint,
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary200,
          backgroundColor: context.customColors.background,
          onRefresh: () => context.read<SupervisorReportsCubit>().load(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), rh(24)),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => context.pushNamed(
                Routes.supervisorReportDetailScreen,
                arguments: {
                  'report': reports[i],
                  'cubit': context.read<SupervisorReportsCubit>(),
                },
                rootNavigator: true,
              ),
              child: SupervisorReportCard(report: reports[i]),
            ),
          ),
        );
      },
    );
  }
}
