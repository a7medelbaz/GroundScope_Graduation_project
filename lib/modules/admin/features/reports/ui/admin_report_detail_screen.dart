import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

Color _severityColor(ReportSeverity s) => switch (s) {
      ReportSeverity.low => AppColors.green200,
      ReportSeverity.medium => AppColors.amber200,
      ReportSeverity.high => AppColors.secondary200,
      ReportSeverity.critical => AppColors.red200,
    };

Color _statusColor(ReportStatus s) => switch (s) {
      ReportStatus.open => AppColors.amber200,
      ReportStatus.acknowledged => AppColors.blue200,
      ReportStatus.inProgress => AppColors.primary200,
      ReportStatus.resolved => AppColors.green200,
    };

Color _directionColor(ReportDirection d) => switch (d) {
      ReportDirection.workerToSupervisor => AppColors.primary200,
      ReportDirection.supervisorToUnit => AppColors.amber200,
      ReportDirection.supervisorToAdmin => AppColors.secondary200,
      ReportDirection.adminToSupervisor => AppColors.red200,
      ReportDirection.adminBroadcast => AppColors.red200,
    };

IconData _typeIcon(ReportType t) => switch (t) {
      ReportType.issue => Icons.warning_rounded,
      ReportType.delay => Icons.timer_off_rounded,
      ReportType.damage => Icons.build_rounded,
      ReportType.safety => Icons.shield_rounded,
      ReportType.other => Icons.description_rounded,
    };

class AdminReportDetailScreen extends StatelessWidget {
  const AdminReportDetailScreen({super.key, required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final cc = context.customColors;
    final statusCol = _statusColor(report.status);
    final severityCol = _severityColor(report.severity);
    final directionCol = _directionColor(report.direction);

    return Scaffold(
      backgroundColor: cc.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                rw(20), topPad + rh(12), rw(20), rh(24)),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary400,
                  AppColors.primary300,
                  AppColors.primary200
                ],
              ),
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: rw(32),
                        height: rw(32),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.white,
                            size: 16),
                      ),
                    ),
                    horizontalSpacing(12),
                    Expanded(
                      child: Text('report_details'.tr(),
                          style: AppTextStyles.font16ExtraBold
                              .copyWith(color: AppColors.white)),
                    ),
                    _DirectionBadge(
                        label: report.direction.label,
                        color: directionCol),
                  ],
                ),
                verticalSpacing(16),
                Row(
                  children: [
                    Container(
                      width: rw(48),
                      height: rw(48),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(rr(12)),
                      ),
                      child: Icon(_typeIcon(report.type),
                          color: AppColors.white, size: rf(24)),
                    ),
                    horizontalSpacing(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${report.type.label} Report',
                            style: AppTextStyles.font18SemiBold
                                .copyWith(color: AppColors.white),
                          ),
                          Text(
                            '#${report.id.substring(0, 8).toUpperCase()}',
                            style: AppTextStyles.font12Light.copyWith(
                                color: AppColors.white
                                    .withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                verticalSpacing(14),
                _StatusBadge(label: report.status.label, color: statusCol),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: 'primary_info'.tr().toUpperCase(),
                    child: Column(children: [
                      _InfoRow(
                          icon: Icons.person_rounded,
                          label: 'filed_by'.tr(),
                          value: report.reporterName ?? '—'),
                      _Divider(),
                      _InfoRow(
                          icon: Icons.flag_rounded,
                          label: 'report_severity'.tr(),
                          value: report.severity.label,
                          valueColor: severityCol),
                      _Divider(),
                      _InfoRow(
                          icon: Icons.access_time_rounded,
                          label: 'filed_at'.tr(),
                          value:
                              '${report.createdAt.formattedDate} · ${report.createdAt.formattedTime}'),
                    ]),
                  ),
                  verticalSpacing(20),
                  if (report.forwarderNotes != null) ...[
                    _SectionCard(
                      title: 'Forwarder Notes'.toUpperCase(),
                      child: Text(
                        report.forwarderNotes!,
                        style: AppTextStyles.font14Light.copyWith(
                            color: cc.textSecondary, height: 1.6),
                      ),
                    ),
                    verticalSpacing(20),
                  ],
                  _SectionCard(
                    title: 'description'.tr().toUpperCase(),
                    child: Text(
                      report.description,
                      style: AppTextStyles.font14Light
                          .copyWith(color: cc.textSecondary, height: 1.6),
                    ),
                  ),
                  if (report.imageUrl != null) ...[
                    verticalSpacing(20),
                    _SectionCard(
                      title: 'attached_evidence'.tr().toUpperCase(),
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(rr(16)),
                        child: CachedNetworkImage(
                          imageUrl: report.imageUrl!,
                          height: rh(220),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            height: rh(220),
                            color: cc.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary200,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            height: rh(220),
                            color: cc.surfaceVariant,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: rf(36),
                                  color: cc.textDisabled,
                                ),
                                verticalSpacing(8),
                                Text(
                                  'image_unavailable'.tr(),
                                  style: AppTextStyles.font12Light
                                      .copyWith(color: cc.textHint),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionBadge extends StatelessWidget {
  const _DirectionBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: AppTextStyles.font12SemiBold.copyWith(color: color)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(8)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(rr(12)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.font12SemiBold
            .copyWith(color: AppColors.white, letterSpacing: 1.0),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title,
      required this.child,
      this.padding});
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.font12SemiBold
                .copyWith(color: cc.textHint, letterSpacing: 1.2)),
        verticalSpacing(8),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: padding ?? EdgeInsets.all(rw(16)),
          decoration: BoxDecoration(
            color: cc.surface,
            borderRadius: BorderRadius.circular(rr(16)),
            border: Border.all(color: cc.border.withValues(alpha: 0.6)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      child: Row(
        children: [
          Icon(icon, size: rr(16), color: cc.iconSecondary),
          horizontalSpacing(10),
          Expanded(
              child: Text(label,
                  style: AppTextStyles.font14Light
                      .copyWith(color: cc.textSecondary))),
          Text(value,
              style: AppTextStyles.font14SemiBold
                  .copyWith(color: valueColor ?? cc.textPrimary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
      height: 1,
      thickness: 1,
      color: context.customColors.divider);
}
