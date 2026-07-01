import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';
import '../logic/cubit/supervisor_reports_cubit.dart';
import 'supervisor_forward_report_screen.dart';

// ─── Color / icon helpers ─────────────────────────────────────────────────────

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

IconData _typeIcon(ReportType t) => switch (t) {
      ReportType.issue => Icons.warning_rounded,
      ReportType.delay => Icons.timer_off_rounded,
      ReportType.damage => Icons.build_rounded,
      ReportType.safety => Icons.shield_rounded,
      ReportType.other => Icons.description_rounded,
    };

IconData _statusIcon(ReportStatus s) => switch (s) {
      ReportStatus.open => Icons.radio_button_unchecked_rounded,
      ReportStatus.acknowledged => Icons.visibility_rounded,
      ReportStatus.inProgress => Icons.pending_actions_rounded,
      ReportStatus.resolved => Icons.check_circle_rounded,
    };

String _roleLabel(String? role) => switch (role) {
      'admin' => 'role_admin',
      'supervisor' => 'role_supervisor',
      _ => 'role_worker',
    };

Color _roleColor(String? role) => switch (role) {
      'admin' => AppColors.red200,
      'supervisor' => AppColors.primary200,
      _ => AppColors.green200,
    };

String _shortId(String id) =>
    id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

// ─── Screen ───────────────────────────────────────────────────────────────────

class SupervisorReportDetailScreen extends StatelessWidget {
  const SupervisorReportDetailScreen({super.key, required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
      buildWhen: (prev, curr) =>
          prev.inbox != curr.inbox ||
          prev.sent != curr.sent ||
          prev.fromAdmin != curr.fromAdmin ||
          prev.actionReportId != curr.actionReportId ||
          prev.status != curr.status,
      builder: (context, state) {
        ReportModel? find(List<ReportModel> list) {
          try {
            return list.firstWhere((r) => r.id == report.id);
          } catch (_) {
            return null;
          }
        }

        final live = find(state.inbox) ??
            find(state.sent) ??
            find(state.fromAdmin) ??
            report;
        final isActionLoading =
            state.status == SupervisorReportsStatus.actionLoading &&
                state.actionReportId == live.id;
        return _ReportDetailView(
          report: live,
          isActionLoading: isActionLoading,
        );
      },
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _ReportDetailView extends StatelessWidget {
  const _ReportDetailView({
    required this.report,
    required this.isActionLoading,
  });

  final ReportModel report;
  final bool isActionLoading;

  void _onAcknowledge(BuildContext context) {
    AppDialogs.showConfirm(
      context,
      message: 'acknowledge_confirm'.tr(),
      confirmText: 'acknowledge'.tr(),
      onConfirm: () =>
          context.read<SupervisorReportsCubit>().acknowledgeReport(report.id),
    );
  }

  void _onResolve(BuildContext context) {
    AppDialogs.showConfirm(
      context,
      message: 'resolve_confirm'.tr(),
      confirmText: 'resolve'.tr(),
      onConfirm: () =>
          context.read<SupervisorReportsCubit>().resolveReport(report.id),
    );
  }

  void _onForward(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SupervisorReportsCubit>(),
          child: SupervisorForwardReportScreen(report: report),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      body: Column(
        children: [
          _GradientHeader(report: report),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: SingleChildScrollView(
                key: ValueKey(report.status),
                padding: EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(40)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrimaryInfoSection(report: report),
                    verticalSpacing(20),
                    _EvidenceSection(report: report),
                    verticalSpacing(20),
                    _DescriptionSection(report: report),
                    verticalSpacing(20),
                    _TimelineSection(report: report),
                    if (report.status != ReportStatus.resolved) ...[
                      verticalSpacing(24),
                      _ActionSection(
                        report: report,
                        isLoading: isActionLoading,
                        onAcknowledge: () => _onAcknowledge(context),
                        onResolve: () => _onResolve(context),
                        onForward: () => _onForward(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient Header ──────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final statusColor = _statusColor(report.status);
    final severityColor = _severityColor(report.severity);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          rw(20), topPadding + rh(12), rw(20), rh(24)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: back button + severity badge ──────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: rw(32),
                  height: rw(32),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
              horizontalSpacing(12),
              Expanded(
                child: Text(
                  'report_details'.tr(),
                  style: AppTextStyles.font16ExtraBold.copyWith(
                    color: AppColors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: rw(10), vertical: rh(5)),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(rr(20)),
                  border: Border.all(
                    color: severityColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: rw(6),
                      height: rw(6),
                      decoration: BoxDecoration(
                        color: severityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    horizontalSpacing(5),
                    Text(
                      'severity_${report.severity.value}'.tr().toUpperCase(),
                      style: AppTextStyles.font12SemiBold.copyWith(
                        color: severityColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(20),
          // ── Row 2: type icon + type label + short ID ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: rw(52),
                height: rw(52),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(rr(14)),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  _typeIcon(report.type),
                  color: AppColors.white,
                  size: rf(26),
                ),
              ),
              horizontalSpacing(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${report.type.label} ${'report'.tr()}',
                      style: AppTextStyles.font22ExtraBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    verticalSpacing(4),
                    Text(
                      '#${_shortId(report.id)}',
                      style: AppTextStyles.font12Light.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(18),
          // ── Status badge ─────────────────────────────────────────────────
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(9)),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(rr(14)),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _statusIcon(report.status),
                  size: rr(16),
                  color: AppColors.white,
                ),
                horizontalSpacing(8),
                Text(
                  report.status.label.toUpperCase(),
                  style: AppTextStyles.font14SemiBold.copyWith(
                    color: AppColors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Primary Info Section ─────────────────────────────────────────────────────

class _PrimaryInfoSection extends StatelessWidget {
  const _PrimaryInfoSection({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final severityColor = _severityColor(report.severity);
    final roleColor = _roleColor(report.reporterRole);

    return _SectionCard(
      title: 'primary_info'.tr().toUpperCase(),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.tag_rounded,
            label: 'report_id'.tr(),
            value: _shortId(report.id),
            valueColor: cc.textPrimary,
          ),
          _RowDivider(),
          _InfoRow(
            icon: _typeIcon(report.type),
            label: 'report_type'.tr(),
            value: report.type.label,
            valueColor: cc.textPrimary,
          ),
          _RowDivider(),
          _InfoRow(
            icon: Icons.flag_rounded,
            label: 'report_severity'.tr(),
            value: 'severity_${report.severity.value}'.tr(),
            valueColor: severityColor,
            isBadge: true,
            badgeColor: severityColor,
          ),
          _RowDivider(),
          // Filed by: name + role badge
          _InfoRowWithBadge(
            icon: Icons.person_rounded,
            label: 'filed_by'.tr(),
            name: report.reporterName ?? '—',
            badgeLabel: _roleLabel(report.reporterRole).tr(),
            badgeColor: roleColor,
          ),
          _RowDivider(),
          if (report.flight != null) ...[
            _InfoRow(
              icon: Icons.flight_rounded,
              label: 'flight_number'.tr(),
              value: report.flight!.flightNumber,
              valueColor: cc.textSecondary,
            ),
            _RowDivider(),
          ],
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'filed_at'.tr(),
            value:
                '${report.createdAt.formattedDate} · ${report.createdAt.formattedTime}',
            valueColor: cc.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ─── Evidence Section ─────────────────────────────────────────────────────────

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'attached_evidence'.tr().toUpperCase(),
      padding: report.imageUrl != null ? EdgeInsets.zero : null,
      child: report.imageUrl != null
          ? _ImageThumbnail(
              imageUrl: report.imageUrl!,
              statusColor: _statusColor(report.status),
            )
          : const _NoEvidencePlaceholder(),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    required this.imageUrl,
    required this.statusColor,
  });

  final String imageUrl;
  final Color statusColor;

  void _openFullScreen(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: AppColors.black.withValues(alpha: 0.95),
      builder: (_) => _FullScreenViewer(imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rr(16)),
        child: SizedBox(
          width: double.infinity,
          height: rh(220),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, p) => Container(
                  color: context.customColors.surfaceVariant,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: rf(36),
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(
                      duration: 1200.ms,
                      color: statusColor.withValues(alpha: 0.15),
                    ),
                errorWidget: (_, p, e) => Container(
                  color: context.customColors.surfaceVariant,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_rounded,
                          size: rf(36),
                          color: context.customColors.textDisabled),
                      verticalSpacing(8),
                      Text(
                        'image_unavailable'.tr(),
                        style: AppTextStyles.font12Light.copyWith(
                            color: context.customColors.textHint),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 1.0],
                      colors: [
                        AppColors.transparent,
                        AppColors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: rh(10),
                left: rw(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: rw(10), vertical: rh(5)),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(rr(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_rounded,
                          size: rr(12), color: AppColors.white),
                      horizontalSpacing(5),
                      Text(
                        'evidence'.tr().toUpperCase(),
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: AppColors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: rh(10),
                right: rw(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: rw(10), vertical: rh(5)),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(rr(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fullscreen_rounded,
                          size: rr(15), color: AppColors.white),
                      horizontalSpacing(4),
                      Text(
                        'tap_to_expand'.tr(),
                        style: AppTextStyles.font12Light
                            .copyWith(color: AppColors.white),
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

class _NoEvidencePlaceholder extends StatelessWidget {
  const _NoEvidencePlaceholder();

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(20)),
      child: Row(
        children: [
          Container(
            width: rw(40),
            height: rh(40),
            decoration: BoxDecoration(
              color: cc.surfaceVariant,
              borderRadius: BorderRadius.circular(rr(10)),
            ),
            child: Center(
              child: Icon(Icons.camera_alt_outlined,
                  size: rf(20), color: cc.textDisabled),
            ),
          ),
          horizontalSpacing(12),
          Text(
            'no_photo_attached'.tr(),
            style:
                AppTextStyles.font14Light.copyWith(color: cc.textHint),
          ),
        ],
      ),
    );
  }
}

// ─── Description Section ──────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'description'.tr().toUpperCase(),
      child: Text(
        report.description,
        style: AppTextStyles.font14Light.copyWith(
          color: context.customColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}

// ─── Timeline Section ─────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final hasAcknowledged = report.acknowledgedAt != null;
    final hasResolved = report.resolvedAt != null;

    return _SectionCard(
      title: 'timeline'.tr().toUpperCase(),
      child: Column(
        children: [
          _TimelineItem(
            color: AppColors.amber200,
            icon: Icons.radio_button_unchecked_rounded,
            label: 'filed'.tr(),
            date:
                '${report.createdAt.formattedDate} ${'at'.tr()} ${report.createdAt.formattedTime}',
            isLast: !hasAcknowledged && !hasResolved,
          ),
          if (hasAcknowledged)
            _TimelineItem(
              color: AppColors.blue200,
              icon: Icons.visibility_rounded,
              label: 'acknowledged'.tr(),
              date:
                  '${report.acknowledgedAt!.formattedDate} ${'at'.tr()} ${report.acknowledgedAt!.formattedTime}',
              isLast: !hasResolved,
            ),
          if (hasResolved)
            _TimelineItem(
              color: AppColors.green200,
              icon: Icons.check_circle_rounded,
              label: 'resolved'.tr(),
              date:
                  '${report.resolvedAt!.formattedDate} ${'at'.tr()} ${report.resolvedAt!.formattedTime}',
              isLast: true,
            ),
        ],
      ),
    );
  }
}

// ─── Action Section ───────────────────────────────────────────────────────────

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.report,
    required this.isLoading,
    required this.onAcknowledge,
    required this.onResolve,
    required this.onForward,
  });

  final ReportModel report;
  final bool isLoading;
  final VoidCallback onAcknowledge;
  final VoidCallback onResolve;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary200),
      );
    }

    return Column(
      children: [
        if (report.status == ReportStatus.open) ...[
          _ActionButton(
            label: 'reports.actions.acknowledge'.tr(),
            icon: Icons.visibility_outlined,
            color: AppColors.blue200,
            onTap: onAcknowledge,
          ),
          verticalSpacing(10),
        ],
        _ActionButton(
          label: 'reports.actions.resolve'.tr(),
          icon: Icons.check_circle_outline,
          color: AppColors.green200,
          onTap: onResolve,
        ),
        if (report.direction == ReportDirection.workerToSupervisor) ...[
          verticalSpacing(10),
          _ActionButton(
            label: 'reports.actions.forward'.tr(),
            icon: Icons.forward_rounded,
            color: AppColors.secondary200,
            onTap: onForward,
          ),
        ],
      ],
    );
  }
}

// ─── Full-Screen Image Viewer ─────────────────────────────────────────────────

class _FullScreenViewer extends StatelessWidget {
  const _FullScreenViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, p) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (_, p, e) => Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.white.withValues(alpha: 0.4),
                    size: rf(48),
                  ),
                ),
              ),
            ),
            Positioned(
              top: topPadding + rh(12),
              right: rw(16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: rw(38),
                  height: rh(38),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rr(10)),
                  ),
                  child: Center(
                    child: Icon(Icons.close_rounded,
                        color: AppColors.white, size: rf(20)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.padding,
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.font12SemiBold.copyWith(
            color: cc.textHint,
            letterSpacing: 1.2,
          ),
        ),
        verticalSpacing(8),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: padding ?? EdgeInsets.all(rw(16)),
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
          child: child,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.isBadge = false,
    this.badgeColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool isBadge;
  final Color? badgeColor;

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
            child: Text(
              label,
              style: AppTextStyles.font14Light.copyWith(
                color: cc.textSecondary,
              ),
            ),
          ),
          if (isBadge && badgeColor != null)
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: rw(10), vertical: rh(3)),
              decoration: BoxDecoration(
                color: badgeColor!.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(rr(8)),
                border:
                    Border.all(color: badgeColor!.withValues(alpha: 0.3)),
              ),
              child: Text(
                value,
                style: AppTextStyles.font12SemiBold
                    .copyWith(color: badgeColor),
              ),
            )
          else
            Text(
              value,
              style:
                  AppTextStyles.font14SemiBold.copyWith(color: valueColor),
            ),
        ],
      ),
    );
  }
}

class _InfoRowWithBadge extends StatelessWidget {
  const _InfoRowWithBadge({
    required this.icon,
    required this.label,
    required this.name,
    required this.badgeLabel,
    required this.badgeColor,
  });

  final IconData icon;
  final String label;
  final String name;
  final String badgeLabel;
  final Color badgeColor;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.font14Light
                      .copyWith(color: cc.textSecondary),
                ),
                verticalSpacing(2),
                Text(
                  name,
                  style: AppTextStyles.font14SemiBold
                      .copyWith(color: cc.textPrimary),
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rr(20)),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: rw(6),
                  height: rw(6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                horizontalSpacing(5),
                Text(
                  badgeLabel,
                  style: AppTextStyles.font12SemiBold
                      .copyWith(color: badgeColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.customColors.divider,
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.color,
    required this.icon,
    required this.label,
    required this.date,
    required this.isLast,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String date;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: rw(28),
              height: rh(28),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: rw(2)),
              ),
              child: Center(
                child: Icon(icon, size: rr(13), color: color),
              ),
            ),
            if (!isLast)
              Container(
                width: rw(2),
                height: rh(28),
                margin: EdgeInsets.symmetric(vertical: rh(2)),
                color: color.withValues(alpha: 0.2),
              ),
          ],
        ),
        horizontalSpacing(14),
        Padding(
          padding: EdgeInsets.only(top: rh(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.font14SemiBold
                    .copyWith(color: cc.textPrimary),
              ),
              verticalSpacing(2),
              Text(
                date,
                style: AppTextStyles.font12Light
                    .copyWith(color: cc.textHint),
              ),
              if (!isLast) verticalSpacing(8),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: rh(14)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: rf(18)),
            horizontalSpacing(8),
            Text(
              label,
              style: AppTextStyles.font14SemiBold.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
