import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});

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

  IconData get _typeIcon => switch (report.type) {
    ReportType.issue => Icons.warning_rounded,
    ReportType.delay => Icons.timer_off_rounded,
    ReportType.damage => Icons.build_rounded,
    ReportType.safety => Icons.shield_rounded,
    ReportType.other => Icons.description_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final severityColor = _severityColor;
    final statusColor = _statusColor;

    return Container(
      margin: EdgeInsets.only(bottom: rh(12)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: cc.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rr(16)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Severity accent bar
              Container(width: rw(4), color: severityColor),

              // Card body
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(rw(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row: icon + type + status chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: rw(42),
                            height: rw(42),
                            decoration: BoxDecoration(
                              color: severityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(rr(12)),
                            ),
                            child: Icon(
                              _typeIcon,
                              color: severityColor,
                              size: rf(20),
                            ),
                          ),
                          horizontalSpacing(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.type.label,
                                  style: AppTextStyles.font16SemiBold.copyWith(
                                    color: cc.textPrimary,
                                  ),
                                ),
                                verticalSpacing(4),
                                _Chip(
                                  label: report.severity.label,
                                  color: severityColor,
                                ),
                              ],
                            ),
                          ),
                          _Chip(
                            label: report.status.label,
                            color: statusColor,
                            filled: true,
                          ),
                        ],
                      ),

                      verticalSpacing(10),

                      // Description
                      Text(
                        report.description,
                        style: AppTextStyles.font14Light.copyWith(
                          color: cc.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      verticalSpacing(10),

                      // Footer: time ago
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: rf(13),
                            color: cc.textHint,
                          ),
                          horizontalSpacing(4),
                          Text(
                            report.createdAt.timeAgo,
                            style: AppTextStyles.font12Light.copyWith(
                              color: cc.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    this.filled = false,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? 0.15 : 0.1),
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
