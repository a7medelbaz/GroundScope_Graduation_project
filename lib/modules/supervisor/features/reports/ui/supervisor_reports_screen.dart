import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/data/models/report_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/extensions/datetime_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../logic/cubit/supervisor_reports_cubit.dart';

class SupervisorReportsScreen extends StatelessWidget {
  const SupervisorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _SupervisorReportsHeader(),
            Expanded(
              child: BlocConsumer<SupervisorReportsCubit, SupervisorReportsState>(
                listener: (context, state) {
                  if (state.status == SupervisorReportsStatus.failure &&
                      state.error != null) {
                    context.showErrorSnackBar(state.error!.messageKey);
                  }
                },
                builder: (context, state) {
                  if (state.status == SupervisorReportsStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary200),
                    );
                  }

                  if (state.status == SupervisorReportsStatus.failure &&
                      state.reports.isEmpty) {
                    return _ErrorBody(
                      message: state.error?.messageKey ??
                          'supervisor_reports.load_failed'.tr(),
                      onRetry: () =>
                          context.read<SupervisorReportsCubit>().loadReports(),
                    );
                  }

                  if (state.reports.isEmpty) {
                    return const _EmptyBody();
                  }

                  return RefreshIndicator(
                    color: AppColors.primary200,
                    backgroundColor: context.customColors.background,
                    onRefresh: () async {
                      await context
                          .read<SupervisorReportsCubit>()
                          .loadReports();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          rw(20), rh(12), rw(20), rh(24)),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.reports.length,
                      itemBuilder: (context, index) {
                        final report = state.reports[index];
                        return _SwipeableReportCard(
                          key: ValueKey(report.id),
                          report: report,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _SupervisorReportsHeader extends StatelessWidget {
  const _SupervisorReportsHeader();

  @override
  Widget build(BuildContext context) {
    final count = context.select<SupervisorReportsCubit, int>(
      (c) => c.state.reports.length,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary400,
            AppColors.primary300,
            AppColors.primary200,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: rw(20),
        right: rw(20),
        top: rh(52),
        bottom: rh(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(46),
            height: rw(46),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.analytics_outlined,
              color: AppColors.white,
              size: rf(22),
            ),
          ),
          horizontalSpacing(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'supervisor_reports.title'.tr(),
                  style: AppTextStyles.font22ExtraBold.copyWith(
                    color: AppColors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                verticalSpacing(2),
                Text(
                  'supervisor_reports.subtitle'.tr(),
                  style: AppTextStyles.font12Light.copyWith(
                    color: AppColors.primary100,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: rw(12),
                vertical: rh(6),
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(rr(20)),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.font16SemiBold.copyWith(
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Swipeable wrapper (logic unchanged) ─────────────────────────────────────

class _SwipeableReportCard extends StatelessWidget {
  const _SwipeableReportCard({super.key, required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isArabic;

    return Dismissible(
      key: ValueKey(report.id),
      direction: isRtl
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
      background: _DeleteBackground(isRtl: isRtl),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) async {
        final success =
            await context.read<SupervisorReportsCubit>().deleteReport(report.id);
        if (success && context.mounted) {
          context.showSuccessSnackBar(
              'supervisor_reports.report_deleted_success'.tr());
        }
      },
      child: _ReportCard(report: report),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('supervisor_dashboard.delete_report_confirm'.tr()),
        content: Text('supervisor_dashboard.delete_report_confirm_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('supervisor_dashboard.cancel'.tr()),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.red200),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('supervisor_dashboard.delete'.tr()),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.isRtl});

  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(12)),
      alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: rw(20)),
      decoration: BoxDecoration(
        color: AppColors.red200.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(16)),
      ),
      child: Icon(Icons.delete_outline_rounded,
          color: AppColors.red200, size: rf(26)),
    );
  }
}

// ─── Report card ─────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

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
                      // Header: icon + type + status chip
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
                        style: AppTextStyles.font14Light
                            .copyWith(color: cc.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      verticalSpacing(10),

                      // Timestamp
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
                            style: AppTextStyles.font12Light
                                .copyWith(color: cc.textHint),
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
    )
        .animate(key: ValueKey(report.id))
        .fade(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut);
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
        color: color.withValues(alpha: filled ? 0.15 : 0.10),
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

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: rf(52), color: cc.textDisabled),
          verticalSpacing(12),
          Text(
            'supervisor_reports.no_reports'.tr(),
            style: AppTextStyles.font16SemiBold.copyWith(color: cc.textSecondary),
          ),
          verticalSpacing(4),
          Text(
            'supervisor_reports.no_reports_subtitle'.tr(),
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: rf(48),
              color: cc.textDisabled,
            ),
            verticalSpacing(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.font14Light.copyWith(
                  color: cc.textSecondary),
            ),
            verticalSpacing(8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('supervisor_dashboard.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
