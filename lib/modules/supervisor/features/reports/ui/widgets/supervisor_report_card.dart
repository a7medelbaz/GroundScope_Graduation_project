import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';

class SupervisorReportCard extends StatelessWidget {
  const SupervisorReportCard({
    super.key,
    required this.report,
    required this.isLoading,
    required this.onAcknowledge,
    required this.onResolve,
  });

  final ReportModel report;
  final bool isLoading;
  final VoidCallback onAcknowledge;
  final VoidCallback onResolve;

  Color _severityColor(BuildContext context) => switch (report.severity) {
        ReportSeverity.low => AppColors.green200,
        ReportSeverity.medium => AppColors.amber200,
        ReportSeverity.high => AppColors.secondary200,
        ReportSeverity.critical => AppColors.red200,
      };

  Color _statusColor(BuildContext context) => switch (report.status) {
        ReportStatus.open => AppColors.amber200,
        ReportStatus.acknowledged => AppColors.primary200,
        ReportStatus.inProgress => AppColors.blue200,
        ReportStatus.resolved => AppColors.green200,
      };

  String get _statusKey => switch (report.status) {
        ReportStatus.open => 'filter_open',
        ReportStatus.acknowledged => 'filter_acknowledged',
        ReportStatus.inProgress => 'filter_in_progress',
        ReportStatus.resolved => 'filter_resolved',
      };

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final severityColor = _severityColor(context);
    final statusColor = _statusColor(context);

    return Container(
      margin: EdgeInsets.only(bottom: rh(12)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: cc.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rr(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top accent bar
            Container(
              height: rh(4),
              color: severityColor,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(rw(14), rh(12), rw(14), rh(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: type icon + flight + status badge
                  Row(
                    children: [
                      Text(
                        report.type.icon,
                        style: TextStyle(fontSize: rf(18)),
                      ),
                      horizontalSpacing(8),
                      Expanded(
                        child: Text(
                          report.flight != null
                              ? report.flight!.flightNumber
                              : '—',
                          style: AppTextStyles.font14ExtraBold
                              .copyWith(color: cc.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      horizontalSpacing(8),
                      _Badge(
                        label: _statusKey.tr(),
                        color: statusColor,
                      ),
                    ],
                  ),
                  verticalSpacing(6),
                  // Description
                  Text(
                    report.description,
                    style:
                        AppTextStyles.font12Light.copyWith(color: cc.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpacing(6),
                  // Reporter + severity row
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: rf(14), color: cc.textHint),
                      horizontalSpacing(4),
                      Expanded(
                        child: Text(
                          report.reporterName ?? '—',
                          style: AppTextStyles.font12Light
                              .copyWith(color: cc.textHint),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _SeverityBadge(
                          label: report.severity.value, color: severityColor),
                    ],
                  ),
                  // Action row
                  if (report.status != ReportStatus.resolved) ...[
                    verticalSpacing(10),
                    if (isLoading)
                      Center(
                        child: SizedBox(
                          width: rw(20),
                          height: rw(20),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary200,
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (report.status == ReportStatus.open)
                            CustomTextButton.outlined(
                              text: 'acknowledge'.tr(),
                              onPressed: onAcknowledge,
                              size: CustomButtonSize.small,
                              isFullWidth: false,
                            ),
                          if (report.status == ReportStatus.open)
                            horizontalSpacing(8),
                          CustomTextButton(
                            text: 'resolve'.tr(),
                            onPressed: onResolve,
                            size: CustomButtonSize.small,
                            isFullWidth: false,
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(8)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'severity_$label'.tr(),
      style: AppTextStyles.font12SemiBold.copyWith(color: color),
    );
  }
}
