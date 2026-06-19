import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/core/widgets/search_with_counter.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';
import 'package:ground_scope/modules/supervisor/core/widgets/supervisor_screen_header.dart';
import '../logic/cubit/supervisor_reports_cubit.dart';
import 'widgets/supervisor_report_card.dart';

// ─── Color helpers (local to this file) ──────────────────────────────────────

Color _severityColor(String v) => switch (v) {
      'critical' => AppColors.red200,
      'high' => AppColors.secondary200,
      'medium' => AppColors.amber200,
      _ => AppColors.green200,
    };

Color _statusColor(String v) => switch (v) {
      'open' => AppColors.amber200,
      'acknowledged' => AppColors.blue200,
      'resolved' => AppColors.green200,
      _ => AppColors.primary200,
    };

// ─── Screen ───────────────────────────────────────────────────────────────────

class SupervisorReportsScreen extends StatefulWidget {
  const SupervisorReportsScreen({super.key});

  @override
  State<SupervisorReportsScreen> createState() =>
      _SupervisorReportsScreenState();
}

class _SupervisorReportsScreenState extends State<SupervisorReportsScreen> {
  static const _statusFilters = ['all', 'open', 'acknowledged', 'resolved'];

  String get _serviceTypeId {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthSuccess ? (auth.userModel.serviceTypeId ?? '') : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<SupervisorReportsCubit>().loadReports(_serviceTypeId);
  }

  void _onAcknowledge(BuildContext ctx, String reportId) {
    AppDialogs.showConfirm(
      ctx,
      message: 'acknowledge_confirm'.tr(),
      confirmText: 'acknowledge'.tr(),
      onConfirm: () =>
          ctx.read<SupervisorReportsCubit>().acknowledgeReport(reportId),
    );
  }

  void _onResolve(BuildContext ctx, String reportId) {
    AppDialogs.showConfirm(
      ctx,
      message: 'resolve_confirm'.tr(),
      confirmText: 'resolve'.tr(),
      onConfirm: () =>
          ctx.read<SupervisorReportsCubit>().resolveReport(reportId),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    final cubit = context.read<SupervisorReportsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: const _AdvancedFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocListener<SupervisorReportsCubit, SupervisorReportsState>(
      listenWhen: (p, c) => c.error != null && p.error != c.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!.messageKey)),
        );
      },
      child: Scaffold(
        backgroundColor: cc.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
              buildWhen: (p, c) =>
                  p.allReports.length != c.allReports.length,
              builder: (context, state) => SupervisorScreenHeader(
                icon: Icons.flag_outlined,
                title: 'supervisor_reports_title'.tr(),
                subtitle: 'from_your_units'.tr(),
                trailing: HeaderCountBadge(count: state.allReports.length),
              ),
            ),
            // ── Search ──────────────────────────────────────────────────
            BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
              buildWhen: (p, c) =>
                  p.resultCount != c.resultCount ||
                  p.searchQuery != c.searchQuery,
              builder: (context, state) => SearchWithCounter(
                hintText: 'search_by_flight_or_description'.tr(),
                onChanged: context.read<SupervisorReportsCubit>().setSearch,
                resultCount: state.resultCount,
              ),
            ),
            // ── Filter bar: status pills + advanced button ───────────────
            BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
              buildWhen: (p, c) =>
                  p.activeFilter != c.activeFilter ||
                  p.activeAdvancedFilterCount != c.activeAdvancedFilterCount,
              builder: (context, state) => _FilterBar(
                statusFilters: _statusFilters,
                activeStatus: state.activeFilter,
                advancedCount: state.activeAdvancedFilterCount,
                onStatusChanged:
                    context.read<SupervisorReportsCubit>().setFilter,
                onAdvancedTap: () => _showAdvancedFilters(context),
              ),
            ),
            // ── Active advanced filter chips ─────────────────────────────
            BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
              buildWhen: (p, c) =>
                  p.activeSeverityFilter != c.activeSeverityFilter ||
                  p.activeRoleFilter != c.activeRoleFilter,
              builder: (context, state) {
                if (state.activeAdvancedFilterCount == 0) {
                  return const SizedBox.shrink();
                }
                return _ActiveFilterChips(
                  severityFilter: state.activeSeverityFilter,
                  roleFilter: state.activeRoleFilter,
                  onClearSeverity: () => context
                      .read<SupervisorReportsCubit>()
                      .setSeverityFilter('all'),
                  onClearRole: () => context
                      .read<SupervisorReportsCubit>()
                      .setRoleFilter('all'),
                );
              },
            ),
            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
                builder: (context, state) {
                  if (state.status == SupervisorReportsStatus.loading ||
                      state.status == SupervisorReportsStatus.initial) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary200),
                    );
                  }
                  if (state.status == SupervisorReportsStatus.failure) {
                    return ErrorScreen(
                      error: state.error?.messageKey,
                      onRetry: () => context
                          .read<SupervisorReportsCubit>()
                          .loadReports(_serviceTypeId),
                    );
                  }
                  if (state.filteredReports.isEmpty) {
                    return _EmptyState();
                  }
                  return RefreshIndicator(
                    color: AppColors.primary200,
                    onRefresh: () => context
                        .read<SupervisorReportsCubit>()
                        .refresh(_serviceTypeId),
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          rw(16), rh(8), rw(16), rh(24)),
                      itemCount: state.filteredReports.length,
                      itemBuilder: (ctx, i) {
                        final report = state.filteredReports[i];
                        final isLoading =
                            state.status ==
                                    SupervisorReportsStatus.actionLoading &&
                                state.actionReportId == report.id;
                        return SupervisorReportCard(
                          report: report,
                          isLoading: isLoading,
                          onAcknowledge: () =>
                              _onAcknowledge(ctx, report.id),
                          onResolve: () => _onResolve(ctx, report.id),
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

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.statusFilters,
    required this.activeStatus,
    required this.advancedCount,
    required this.onStatusChanged,
    required this.onAdvancedTap,
  });

  final List<String> statusFilters;
  final String activeStatus;
  final int advancedCount;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onAdvancedTap;

  static const _statusLabels = [
    'filter_all',
    'filter_open',
    'filter_acknowledged',
    'filter_resolved',
  ];

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.only(
          left: rw(16), right: rw(16), top: rh(6), bottom: rh(2)),
      child: Row(
        children: [
          // Scrollable status pills
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(statusFilters.length, (i) {
                  final key = statusFilters[i];
                  final isActive = activeStatus == key;
                  final chipColor = key == 'all'
                      ? AppColors.primary200
                      : _statusColor(key);

                  return Padding(
                    padding: EdgeInsets.only(right: rw(8)),
                    child: GestureDetector(
                      onTap: () => onStatusChanged(key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: rw(14), vertical: rh(7)),
                        decoration: BoxDecoration(
                          color: isActive
                              ? chipColor
                              : cc.surfaceVariant,
                          borderRadius: BorderRadius.circular(rr(20)),
                          border: Border.all(
                            color: isActive ? chipColor : cc.border,
                          ),
                        ),
                        child: Text(
                          _statusLabels[i].tr(),
                          style: AppTextStyles.font12SemiBold.copyWith(
                            color: isActive
                                ? AppColors.white
                                : cc.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          horizontalSpacing(8),
          // Advanced filter button
          GestureDetector(
            onTap: onAdvancedTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                  horizontal: rw(12), vertical: rh(7)),
              decoration: BoxDecoration(
                color: advancedCount > 0
                    ? AppColors.primary200
                    : cc.surfaceVariant,
                borderRadius: BorderRadius.circular(rr(20)),
                border: Border.all(
                  color: advancedCount > 0
                      ? AppColors.primary200
                      : cc.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: rf(14),
                    color: advancedCount > 0
                        ? AppColors.white
                        : cc.textSecondary,
                  ),
                  if (advancedCount > 0) ...[
                    horizontalSpacing(5),
                    Container(
                      width: rw(16),
                      height: rw(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$advancedCount',
                          style: AppTextStyles.font12SemiBold.copyWith(
                            color: AppColors.white,
                            fontSize: rf(10),
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

// ─── Active filter chips (shown when advanced filters are on) ─────────────────

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({
    required this.severityFilter,
    required this.roleFilter,
    required this.onClearSeverity,
    required this.onClearRole,
  });

  final String severityFilter;
  final String roleFilter;
  final VoidCallback onClearSeverity;
  final VoidCallback onClearRole;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: rw(16), right: rw(16), bottom: rh(4)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (severityFilter != 'all')
              _ActiveChip(
                label: 'severity_$severityFilter'.tr(),
                color: _severityColor(severityFilter),
                onRemove: onClearSeverity,
              ),
            if (severityFilter != 'all' && roleFilter != 'all')
              horizontalSpacing(6),
            if (roleFilter != 'all')
              _ActiveChip(
                label: roleFilter == 'admin'
                    ? 'role_admin'.tr()
                    : 'role_worker'.tr(),
                color: roleFilter == 'admin'
                    ? AppColors.red200
                    : AppColors.primary200,
                onRemove: onClearRole,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  final String label;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: rw(10), right: rw(6), top: rh(5), bottom: rh(5)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style:
                AppTextStyles.font12SemiBold.copyWith(color: color),
          ),
          horizontalSpacing(4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: rf(13), color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Advanced filter bottom sheet ─────────────────────────────────────────────

class _AdvancedFilterSheet extends StatelessWidget {
  const _AdvancedFilterSheet();

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
      builder: (context, state) {
        final cubit = context.read<SupervisorReportsCubit>();
        final hasActive = state.activeAdvancedFilterCount > 0;

        return Container(
          decoration: BoxDecoration(
            color: cc.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(rr(24)),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              rw(20), rh(12), rw(20), rh(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: rw(36),
                  height: rh(4),
                  decoration: BoxDecoration(
                    color: cc.border,
                    borderRadius: BorderRadius.circular(rr(2)),
                  ),
                ),
              ),
              verticalSpacing(16),
              // Title row
              Row(
                children: [
                  Icon(Icons.tune_rounded,
                      size: rf(18), color: AppColors.primary200),
                  horizontalSpacing(8),
                  Text(
                    'advanced_filters'.tr(),
                    style: AppTextStyles.font16ExtraBold
                        .copyWith(color: cc.textPrimary),
                  ),
                  const Spacer(),
                  if (hasActive)
                    GestureDetector(
                      onTap: () {
                        cubit.clearAdvancedFilters();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'clear_all_filters'.tr(),
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: AppColors.red200,
                        ),
                      ),
                    ),
                ],
              ),
              verticalSpacing(24),
              // Severity section
              _SheetSectionLabel(text: 'filter_severity'.tr()),
              verticalSpacing(10),
              _SeverityChips(
                active: state.activeSeverityFilter,
                onChanged: cubit.setSeverityFilter,
              ),
              verticalSpacing(22),
              // Filed By section
              _SheetSectionLabel(text: 'filter_filed_by'.tr()),
              verticalSpacing(10),
              _RoleChips(
                active: state.activeRoleFilter,
                onChanged: cubit.setRoleFilter,
              ),
              verticalSpacing(8),
            ],
          ),
        );
      },
    );
  }
}

class _SheetSectionLabel extends StatelessWidget {
  const _SheetSectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.font12SemiBold.copyWith(
        color: context.customColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SeverityChips extends StatelessWidget {
  const _SeverityChips({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('all', null),
    ('critical', AppColors.red200),
    ('high', AppColors.secondary200),
    ('medium', AppColors.amber200),
    ('low', AppColors.green200),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: rw(8),
      runSpacing: rh(8),
      children: _options.map((opt) {
        final (key, color) = opt;
        final isActive = active == key;
        return _FilterChipOption(
          label: key == 'all'
              ? 'filter_all'.tr()
              : 'severity_$key'.tr(),
          color: color,
          isActive: isActive,
          onTap: () => onChanged(key),
        );
      }).toList(),
    );
  }
}

class _RoleChips extends StatelessWidget {
  const _RoleChips({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: rw(8),
      runSpacing: rh(8),
      children: [
        _FilterChipOption(
          label: 'filter_all'.tr(),
          color: null,
          isActive: active == 'all',
          onTap: () => onChanged('all'),
        ),
        _FilterChipOption(
          label: 'role_admin'.tr(),
          color: AppColors.red200,
          isActive: active == 'admin',
          onTap: () => onChanged('admin'),
        ),
        _FilterChipOption(
          label: 'role_worker'.tr(),
          color: AppColors.primary200,
          isActive: active == 'worker',
          onTap: () => onChanged('worker'),
        ),
      ],
    );
  }
}

class _FilterChipOption extends StatelessWidget {
  const _FilterChipOption({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final Color? color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final effectiveColor = color ?? AppColors.primary200;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
            horizontal: rw(14), vertical: rh(9)),
        decoration: BoxDecoration(
          color: isActive
              ? effectiveColor.withValues(alpha: 0.12)
              : cc.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(
            color: isActive
                ? effectiveColor
                : cc.border.withValues(alpha: 0.7),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: rw(8),
                height: rw(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              horizontalSpacing(6),
            ] else if (isActive) ...[
              Icon(Icons.check_rounded,
                  size: rf(13), color: effectiveColor),
              horizontalSpacing(5),
            ],
            Text(
              label,
              style: AppTextStyles.font12SemiBold.copyWith(
                color: isActive ? effectiveColor : cc.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: rf(64), color: cc.iconSecondary),
            verticalSpacing(16),
            Text(
              'no_results_found'.tr(),
              style: AppTextStyles.font16SemiBold
                  .copyWith(color: cc.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
