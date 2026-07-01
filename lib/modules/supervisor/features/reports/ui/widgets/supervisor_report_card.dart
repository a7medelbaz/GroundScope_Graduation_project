import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class SupervisorReportCard extends StatelessWidget {
  const SupervisorReportCard({super.key, required this.report});

  final ReportModel report;

  Color get _severityColor => switch (report.severity) {
    ReportSeverity.low => AppColors.green200,
    ReportSeverity.medium => AppColors.amber200,
    ReportSeverity.high => AppColors.secondary200,
    ReportSeverity.critical => AppColors.red200,
  };

  Color get _statusColor => switch (report.status) {
    ReportStatus.open => AppColors.amber200,
    ReportStatus.acknowledged => AppColors.blue200,
    ReportStatus.inProgress => AppColors.primary200,
    ReportStatus.resolved => AppColors.green200,
  };

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

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
            Container(height: rh(4), color: _severityColor),
            Padding(
              padding: EdgeInsets.fromLTRB(rw(14), rh(12), rw(14), rh(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        report.type.icon,
                        style: TextStyle(fontSize: rf(18)),
                      ),
                      horizontalSpacing(8),
                      Expanded(
                        child: Text(
                          report.reporterName ??
                              report.flight?.flightNumber ??
                              '—',
                          style: AppTextStyles.font14ExtraBold.copyWith(
                            color: cc.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      horizontalSpacing(8),
                      _Badge(label: report.status.label, color: _statusColor),
                    ],
                  ),
                  verticalSpacing(6),
                  Text(
                    report.description,
                    style: AppTextStyles.font12Light.copyWith(
                      color: cc.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpacing(6),
                  Row(
                    children: [
                      _DirectionBadge(direction: report.direction),
                      const Spacer(),
                      Text(
                        report.severity.label,
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: _severityColor,
                        ),
                      ),
                    ],
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

class _DirectionBadge extends StatelessWidget {
  const _DirectionBadge({required this.direction});
  final ReportDirection direction;

  Color get _color => switch (direction) {
    ReportDirection.workerToSupervisor => AppColors.primary200,
    ReportDirection.supervisorToUnit => AppColors.amber200,
    ReportDirection.supervisorToAdmin => AppColors.secondary200,
    ReportDirection.adminToSupervisor => AppColors.red200,
    ReportDirection.adminBroadcast => AppColors.red200,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(6), vertical: rh(2)),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rr(6)),
      ),
      child: Text(
        direction.label,
        style: AppTextStyles.font12Light.copyWith(color: _color),
      ),
    );
  }
}
