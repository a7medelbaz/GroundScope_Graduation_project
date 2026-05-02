import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_font_weight.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import '../logic/cubit/reports_cubit.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _severityColor(ReportSeverity s) => switch (s) {
  ReportSeverity.low      => AppColors.green200,
  ReportSeverity.medium   => AppColors.amber200,
  ReportSeverity.high     => AppColors.secondary200,
  ReportSeverity.critical => AppColors.red200,
};

Color _statusColor(ReportStatus s) => switch (s) {
  ReportStatus.open         => AppColors.amber200,
  ReportStatus.acknowledged => AppColors.blue200,
  ReportStatus.inProgress   => AppColors.primary200,
  ReportStatus.resolved     => AppColors.green200,
};

IconData _typeIcon(ReportType t) => switch (t) {
  ReportType.issue  => Icons.warning_rounded,
  ReportType.delay  => Icons.timer_off_rounded,
  ReportType.damage => Icons.build_rounded,
  ReportType.safety => Icons.shield_rounded,
  ReportType.other  => Icons.description_rounded,
};

IconData _statusIcon(ReportStatus s) => switch (s) {
  ReportStatus.open         => Icons.radio_button_unchecked_rounded,
  ReportStatus.acknowledged => Icons.visibility_rounded,
  ReportStatus.inProgress   => Icons.pending_actions_rounded,
  ReportStatus.resolved     => Icons.check_circle_rounded,
};

String _shortId(String id) =>
    id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

// ─── Screen ───────────────────────────────────────────────────────────────────

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      buildWhen: (prev, curr) =>
          prev.reports != curr.reports || prev.status != curr.status,
      builder: (context, state) {
        final live = state.reports.firstWhere(
          (r) => r.id == report.id,
          orElse: () => report,
        );
        return _ReportDetailsView(
          report: live,
          isRefreshing: state.status == ReportsStatus.loading,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReportDetailsView extends StatelessWidget {
  const _ReportDetailsView({required this.report, required this.isRefreshing});

  final ReportModel report;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _Header(report: report, isRefreshing: isRefreshing),
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

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.report, required this.isRefreshing});

  final ReportModel report;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final statusColor = _statusColor(report.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(rw(20), topPadding + rh(12), rw(20), rh(24)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary400, AppColors.primary300, AppColors.primary200],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(rr(28))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NavButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
              const Spacer(),
              _NavButton(
                icon: Icons.refresh_rounded,
                isLoading: isRefreshing,
                onTap: isRefreshing
                    ? null
                    : () => context.read<ReportsCubit>().fetchMyReports(),
              ),
            ],
          ),
          verticalSpacing(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: rw(52),
                height: rh(52),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(rr(16)),
                ),
                child: Center(
                  child: Icon(
                    _typeIcon(report.type),
                    color: AppColors.white,
                    size: rf(26),
                  ),
                ),
              ),
              horizontalSpacing(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${report.type.label} Report',
                      style: AppTextStyles.font18SemiBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    verticalSpacing(4),
                    Text(
                      '#${_shortId(report.id)}',
                      style: AppTextStyles.font12Light.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontWeight: AppFontWeight.medium,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(18),
          Container(
            padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(9)),
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
                Icon(_statusIcon(report.status), size: rr(16), color: AppColors.white),
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: rw(36),
        height: rh(36),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(rr(10)),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: rw(16),
                  height: rh(16),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Icon(icon, color: AppColors.white, size: rf(18)),
        ),
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

    return _SectionCard(
      title: 'PRIMARY INFO',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.tag_rounded,
            label: 'Report ID',
            value: _shortId(report.id),
            valueColor: cc.textPrimary,
          ),
          _RowDivider(),
          _InfoRow(
            icon: _typeIcon(report.type),
            label: 'Type',
            value: report.type.label,
            valueColor: cc.textPrimary,
          ),
          _RowDivider(),
          _InfoRow(
            icon: Icons.flag_rounded,
            label: 'Severity',
            value: report.severity.label,
            valueColor: severityColor,
            isBadge: true,
            badgeColor: severityColor,
          ),
          _RowDivider(),
          _InfoRow(
            icon: Icons.flight_rounded,
            label: 'Flight',
            value: _shortId(report.flightId),
            valueColor: cc.textSecondary,
          ),
          _RowDivider(),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Filed',
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
      title: 'ATTACHED EVIDENCE',
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
                placeholder: (context, url) => _ImageShimmer(
                  accentColor: statusColor,
                ),
                errorWidget: (context, url, error) => const _ImageError(),
              ),
              // Gradient overlay for readability of the hint label
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
              // Status-colored top-left badge
              Positioned(
                top: rh(10),
                left: rw(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(10),
                    vertical: rh(5),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(rr(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: rr(12),
                        color: AppColors.white,
                      ),
                      horizontalSpacing(5),
                      Text(
                        'EVIDENCE',
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: AppColors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Expand hint — bottom-right
              Positioned(
                bottom: rh(10),
                right: rw(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(10),
                    vertical: rh(5),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(rr(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fullscreen_rounded,
                        size: rr(15),
                        color: AppColors.white,
                      ),
                      horizontalSpacing(4),
                      Text(
                        'Tap to expand',
                        style: AppTextStyles.font12Light.copyWith(
                          color: AppColors.white,
                        ),
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

class _ImageShimmer extends StatelessWidget {
  const _ImageShimmer({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.customColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: rf(36),
          color: accentColor.withValues(alpha: 0.3),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 1200.ms,
          color: accentColor.withValues(alpha: 0.15),
        );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Container(
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
            'Image unavailable',
            style: AppTextStyles.font12Light.copyWith(color: cc.textHint),
          ),
        ],
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
              child: Icon(
                Icons.camera_alt_outlined,
                size: rf(20),
                color: cc.textDisabled,
              ),
            ),
          ),
          horizontalSpacing(12),
          Text(
            'No photo attached',
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
          ),
        ],
      ),
    );
  }
}

// ─── Full-Screen Viewer ───────────────────────────────────────────────────────

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
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
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
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: rf(20),
                    ),
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

// ─── Description Section ──────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'DESCRIPTION',
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
      title: 'TIMELINE',
      child: Column(
        children: [
          _TimelineItem(
            color: AppColors.amber200,
            icon: Icons.radio_button_unchecked_rounded,
            label: 'Filed',
            date:
                '${report.createdAt.formattedDate} at ${report.createdAt.formattedTime}',
            isLast: !hasAcknowledged && !hasResolved,
          ),
          if (hasAcknowledged)
            _TimelineItem(
              color: AppColors.blue200,
              icon: Icons.visibility_rounded,
              label: 'Acknowledged',
              date:
                  '${report.acknowledgedAt!.formattedDate} at ${report.acknowledgedAt!.formattedTime}',
              isLast: !hasResolved,
            ),
          if (hasResolved)
            _TimelineItem(
              color: AppColors.green200,
              icon: Icons.check_circle_rounded,
              label: 'Resolved',
              date:
                  '${report.resolvedAt!.formattedDate} at ${report.resolvedAt!.formattedTime}',
              isLast: true,
            ),
        ],
      ),
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
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: cc.textPrimary,
                ),
              ),
              verticalSpacing(2),
              Text(
                date,
                style: AppTextStyles.font12Light.copyWith(color: cc.textHint),
              ),
              if (!isLast) verticalSpacing(8),
            ],
          ),
        ),
      ],
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
                horizontal: rw(10),
                vertical: rh(3),
              ),
              decoration: BoxDecoration(
                color: badgeColor!.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(rr(8)),
                border: Border.all(color: badgeColor!.withValues(alpha: 0.3)),
              ),
              child: Text(
                value,
                style: AppTextStyles.font12SemiBold.copyWith(
                  color: badgeColor,
                ),
              ),
            )
          else
            Text(
              value,
              style: AppTextStyles.font14SemiBold.copyWith(color: valueColor),
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
