import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart';
import 'package:ground_scope/modules/supervisor/features/reports/ui/widgets/report_tab_chip.dart';

class SupervisorReportTabBar extends StatelessWidget {
  const SupervisorReportTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
      buildWhen: (p, c) =>
          p.tab != c.tab ||
          p.inbox.length != c.inbox.length ||
          p.sent.length != c.sent.length ||
          p.fromAdmin.length != c.fromAdmin.length ||
          p.unreadInbox != c.unreadInbox,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), 0),
          child: Row(
            children: [
              SupervisorReportTabChip(
                label: 'reports.tabs.inbox'.tr(),
                count: state.inbox.length,
                badge: state.unreadInbox,
                active: state.tab == SupervisorReportsTab.inbox,
                onTap: () => context.read<SupervisorReportsCubit>().switchTab(
                  SupervisorReportsTab.inbox,
                ),
              ),
              horizontalSpacing(6),
              SupervisorReportTabChip(
                label: 'reports.tabs.sent'.tr(),
                count: state.sent.length,
                active: state.tab == SupervisorReportsTab.sent,
                onTap: () => context.read<SupervisorReportsCubit>().switchTab(
                  SupervisorReportsTab.sent,
                ),
              ),
              horizontalSpacing(6),
              SupervisorReportTabChip(
                label: 'reports.tabs.from_admin'.tr(),
                count: state.fromAdmin.length,
                active: state.tab == SupervisorReportsTab.fromAdmin,
                onTap: () => context.read<SupervisorReportsCubit>().switchTab(
                  SupervisorReportsTab.fromAdmin,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
