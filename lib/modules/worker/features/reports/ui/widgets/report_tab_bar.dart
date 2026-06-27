import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/reports/logic/cubit/reports_cubit.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/widgets/report_tab_chip.dart';

class ReportTabBar extends StatelessWidget {
  const ReportTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      buildWhen: (p, c) =>
          p.tab != c.tab || p.sent != c.sent || p.received != c.received,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(12)),
          child: Row(
            children: [
              ReportTabChip(
                label: 'reports.tabs.sent'.tr(),
                count: state.sent.length,
                active: state.tab == ReportsTab.sent,
                onTap: () =>
                    context.read<ReportsCubit>().switchTab(ReportsTab.sent),
              ),
              horizontalSpacing(8),
              ReportTabChip(
                label: 'reports.tabs.received'.tr(),
                count: state.received.length,
                active: state.tab == ReportsTab.received,
                onTap: () =>
                    context.read<ReportsCubit>().switchTab(ReportsTab.received),
              ),
            ],
          ),
        );
      },
    );
  }
}
