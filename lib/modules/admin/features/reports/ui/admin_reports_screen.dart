import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';

import '../logic/cubit/admin_reports_cubit.dart';
import 'widgets/admin_report_card.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  void _showSendOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.customColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(20))),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(rw(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionTile(
                icon: Icons.supervisor_account_rounded,
                label: 'reports.actions.select_supervisor'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    Routes.adminSendReportScreen,
                    arguments: {
                      'isBroadcast': false,
                      'cubit': context.read<AdminReportsCubit>(),
                    },
                    rootNavigator: true,
                  );
                },
              ),
              verticalSpacing(8),
              _ActionTile(
                icon: Icons.campaign_rounded,
                label: 'reports.broadcast'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    Routes.adminSendReportScreen,
                    arguments: {
                      'isBroadcast': true,
                      'cubit': context.read<AdminReportsCubit>(),
                    },
                    rootNavigator: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocListener<AdminReportsCubit, AdminReportsState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == AdminReportsStatus.submitSuccess) {
          context.showMessageSnackBar(
            'reports.send_form.send'.tr(),
            type: SnackBarType.success,
          );
          context.read<AdminReportsCubit>().resetSubmitStatus();
        }
      },
      child: Scaffold(
        backgroundColor: cc.background,
        body: SafeArea(
          child: Column(
            children: [
              _Header(onSend: _showSendOptions),
              const _SearchField(),
              const _TabBar(),
              const _DirectionFilterChips(),
              const Expanded(child: _Body()),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onSend});
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(rw(20), rh(16), rw(20), rh(20)),
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'reports.title'.tr(),
              style: AppTextStyles.font22ExtraBold.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: rw(14),
                vertical: rh(8),
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(rr(12)),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                  horizontalSpacing(6),
                  Text(
                    'reports.send_report'.tr(),
                    style: AppTextStyles.font12SemiBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Field ───────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), 0),
      child: CustomTextForm(
        hintText: 'reports.search_hint'.tr(),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: context.customColors.iconSecondary,
        ),
        onChanged: (value) =>
            context.read<AdminReportsCubit>().setSearch(value),
      ),
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReportsCubit, AdminReportsState>(
      buildWhen: (p, c) => p.tab != c.tab,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), 0),
          child: Row(
            children: AdminReportsTab.values.map((tab) {
              final active = state.tab == tab;
              final label = switch (tab) {
                AdminReportsTab.all => 'reports.tabs.all'.tr(),
                AdminReportsTab.communication =>
                  'reports.tabs.communication'.tr(),
                AdminReportsTab.myReports => 'reports.tabs.my_reports'.tr(),
              };
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: tab != AdminReportsTab.myReports ? rw(6) : 0,
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        context.read<AdminReportsCubit>().switchTab(tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: rh(9)),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary200
                            : context.customColors.surface,
                        borderRadius: BorderRadius.circular(rr(10)),
                        border: Border.all(
                          color: active
                              ? AppColors.primary200
                              : context.customColors.border,
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: active
                              ? AppColors.white
                              : context.customColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─── Direction Filter Chips ───────────────────────────────────────────────────

class _DirectionFilterChips extends StatelessWidget {
  const _DirectionFilterChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReportsCubit, AdminReportsState>(
      buildWhen: (p, c) => p.directionFilter != c.directionFilter,
      builder: (context, state) {
        return SizedBox(
          height: rh(44),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(6)),
            children: [
              _FilterChip(
                label: 'reports.tabs.all'.tr(),
                active: state.directionFilter == null,
                onTap: () =>
                    context.read<AdminReportsCubit>().filterByDirection(null),
              ),
              ...ReportDirection.values.map(
                (d) => _FilterChip(
                  label: d.label,
                  active: state.directionFilter == d,
                  onTap: () =>
                      context.read<AdminReportsCubit>().filterByDirection(d),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: rw(8)),
        padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(4)),
        decoration: BoxDecoration(
          color: active ? AppColors.primary200 : context.customColors.surface,
          borderRadius: BorderRadius.circular(rr(20)),
          border: Border.all(
            color: active ? AppColors.primary200 : context.customColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.font12SemiBold.copyWith(
            color: active
                ? AppColors.white
                : context.customColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReportsCubit, AdminReportsState>(
      builder: (context, state) {
        if (state.status == AdminReportsStatus.initial ||
            state.status == AdminReportsStatus.loading) {
          return const _ShimmerList();
        }

        if (state.status == AdminReportsStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: rf(48),
                  color: context.customColors.textDisabled,
                ),
                verticalSpacing(12),
                Text(
                  state.error?.messageKey ?? 'something_went_wrong'.tr(),
                  style: AppTextStyles.font14Light.copyWith(
                    color: context.customColors.textSecondary,
                  ),
                ),
                verticalSpacing(8),
                TextButton.icon(
                  onPressed: () => context.read<AdminReportsCubit>().load(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }

        final reports = state.displayList;

        if (reports.isEmpty) {
          return Center(
            child: Text(
              'reports.empty.no_sent'.tr(),
              style: AppTextStyles.font14Light.copyWith(
                color: context.customColors.textHint,
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary200,
          backgroundColor: context.customColors.background,
          onRefresh: () => context.read<AdminReportsCubit>().load(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), rh(24)),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => context.pushNamed(
                Routes.adminReportDetailScreen,
                arguments: {'report': reports[i]},
                rootNavigator: true,
              ),
              child: AdminReportCard(report: reports[i]),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), rh(24)),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        margin: EdgeInsets.only(bottom: rh(12)),
        height: rh(80),
        decoration: BoxDecoration(
          color: context.customColors.surface,
          borderRadius: BorderRadius.circular(rr(16)),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      tileColor: context.customColors.surfaceVariant,
      leading: Icon(icon, color: AppColors.primary200),
      title: Text(label, style: AppTextStyles.font14SemiBold),
    );
  }
}
