import 'package:flutter/material.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/widgets/report_screen_body.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/widgets/report_tab_bar.dart';

import 'widgets/reports_app_bar.dart';
import 'widgets/reports_filter_strip.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      top: false,
      child: Column(
        children: [
          ReportsAppBar(),
          ReportTabBar(),
          ReportsFilterStrip(),
          Expanded(child: ReportScreenBody()),
        ],
      ),
    );
  }
}
