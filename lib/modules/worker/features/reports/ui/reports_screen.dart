import 'package:flutter/material.dart';
import 'package:ground_scope/core/extensions/context_extensions.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/reports/data/models/report_model.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../core/widgets/info_summary_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newReport = ReportModel(
      title: 'Flight BA2490 - A380 PushBack',
      description: 'Daily status update',
      date: DateTime.now(), // Pass it here
      hourlyData: {},
      images: [],
    );
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            verticalSpacing(25),
            Text(
              'Reports',
              style: AppTextStyles.font20Bold,
              textAlign: TextAlign.center,
            ),
            verticalSpacing(16),
            InfoSummaryTile(
              report: newReport,
              onTap: () {
                context.pushNamed(
                  Routes.reportDetailsScreen,
                  arguments: {
                    'report':
                        newReport, // This is the key 'report' being passed
                  },
                );
              },
            ),
            // ReportCard(
            //   report: newReport,
            //   onTap: () {
            //     context.pushNamed(
            //       Routes.reportDetailsScreen,
            //       arguments: {
            //         'report':
            //             newReport, // This is the key 'report' being passed
            //       },
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
