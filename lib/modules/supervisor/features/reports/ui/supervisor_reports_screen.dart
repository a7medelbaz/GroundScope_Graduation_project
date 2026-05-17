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
      appBar: AppBar(
        backgroundColor: cc.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'supervisor_reports.title'.tr(),
          style: AppTextStyles.font20SemiBold.copyWith(color: cc.textPrimary),
        ),
      ),
      body: BlocConsumer<SupervisorReportsCubit, SupervisorReportsState>(
        listener: (context, state) {
          if (state.status == SupervisorReportsStatus.failure &&
              state.error != null) {
            context.showErrorSnackBar(state.error!.messageKey);
          }
        },
        builder: (context, state) {
          if (state.status == SupervisorReportsStatus.loading) {
            return _ReportsLoadingSkeleton();
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
            return _EmptyBody();
          }

          return RefreshIndicator(
            color: AppColors.primary200,
            onRefresh: () async {
              await context.read<SupervisorReportsCubit>().loadReports();
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: rw(16), vertical: rh(12)),
              itemCount: state.reports.length,
              separatorBuilder: (context, index) => verticalSpacing(10),
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
    );
  }
}

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
            style: TextButton.styleFrom(
                foregroundColor: AppColors.red200),
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

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final ReportModel report;

  Color _severityColor() => switch (report.severity) {
        ReportSeverity.low => AppColors.green200,
        ReportSeverity.medium => AppColors.amber200,
        ReportSeverity.high => AppColors.secondary200,
        ReportSeverity.critical => AppColors.red200,
      };

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final severityColor = _severityColor();

    return Container(
      padding: EdgeInsets.all(rw(14)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: rw(40),
            height: rw(40),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rr(10)),
            ),
            child: Center(
              child: Text(report.type.icon,
                  style: TextStyle(fontSize: rf(18))),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.type.label,
                        style: AppTextStyles.font14SemiBold.copyWith(
                            color: cc.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    horizontalSpacing(8),
                    _SeverityChip(
                        label: report.severity.label,
                        color: severityColor),
                  ],
                ),
                verticalSpacing(4),
                Text(
                  report.description,
                  style: AppTextStyles.font12Light.copyWith(
                      color: cc.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpacing(6),
                Text(
                  report.createdAt.formattedDateTime,
                  style: AppTextStyles.font12Light.copyWith(
                      color: cc.textHint, fontSize: rf(11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.font12Light.copyWith(
          color: color,
          fontSize: rf(10),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined,
              size: rf(56), color: cc.textHint),
          verticalSpacing(16),
          Text(
            'supervisor_reports.no_reports'.tr(),
            style: AppTextStyles.font16SemiBold.copyWith(
                color: cc.textHint),
          ),
        ],
      ),
    );
  }
}

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: rf(52), color: AppColors.red200),
            verticalSpacing(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.font14SemiBold.copyWith(
                  color: cc.textSecondary),
            ),
            verticalSpacing(20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('supervisor_dashboard.retry'.tr()),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary200),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsLoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:
          EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(12)),
      itemCount: 6,
      separatorBuilder: (context, index) => verticalSpacing(10),
      itemBuilder: (context, index) => _ReportCardSkeleton(),
    );
  }
}

class _ReportCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      padding: EdgeInsets.all(rw(14)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: rw(40),
            height: rw(40),
            decoration: BoxDecoration(
              color: cc.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(rr(10)),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 1200.ms,
                color: cc.border.withValues(alpha: 0.6),
              ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: rh(14),
                        decoration: BoxDecoration(
                          color: cc.border.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(rr(4)),
                        ),
                      ).animate(onPlay: (c) => c.repeat()).shimmer(
                            duration: 1200.ms,
                            color: cc.border.withValues(alpha: 0.6),
                          ),
                    ),
                    horizontalSpacing(8),
                    Container(
                      width: rw(56),
                      height: rh(20),
                      decoration: BoxDecoration(
                        color: cc.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(rr(20)),
                      ),
                    ).animate(onPlay: (c) => c.repeat()).shimmer(
                          duration: 1200.ms,
                          color: cc.border.withValues(alpha: 0.6),
                        ),
                  ],
                ),
                verticalSpacing(6),
                Container(
                  height: rh(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cc.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(rr(4)),
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(
                      duration: 1200.ms,
                      color: cc.border.withValues(alpha: 0.6),
                    ),
                verticalSpacing(4),
                Container(
                  height: rh(10),
                  width: rw(120),
                  decoration: BoxDecoration(
                    color: cc.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(rr(4)),
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(
                      duration: 1200.ms,
                      color: cc.border.withValues(alpha: 0.6),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
