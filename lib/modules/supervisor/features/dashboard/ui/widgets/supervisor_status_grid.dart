import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/modules/supervisor/core/main_navigation/cubit/supervisor_bottom_nav_cubit.dart';
import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../../core/utils/spacing.dart';
import '../../logic/cubit/supervisor_dashboard_cubit.dart';
import '../../../../../../core/router/routes.dart';

class SupervisorStatsGrid extends StatelessWidget {
  const SupervisorStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupervisorDashboardCubit, SupervisorDashboardState>(
      builder: (context, state) {
        final isLoading = state.status == DashboardStatus.loading;
        final stats = state.stats;

        if (isLoading && stats == null) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: rw(12),
            mainAxisSpacing: rh(12),
            childAspectRatio: 1.55,
            children: const [
              _StatCardSkeleton(),
              _StatCardSkeleton(),
              _StatCardSkeleton(),
              _StatCardSkeleton(),
            ],
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: rw(12),
          mainAxisSpacing: rh(12),
          childAspectRatio: 1.55,
          children: [
            _StatCard(
              icon: Icons.groups_outlined,
              label: 'supervisor_dashboard.active_units'.tr(),
              value: stats?.activeUnits?.toString() ?? '—',
              iconColor: AppColors.primary200,
              onTap: () => context
                  .showSnackBar('supervisor_dashboard.active_units_coming_soon'.tr()),
            ),
            _StatCard(
              icon: Icons.check_circle_outline,
              label: 'supervisor_dashboard.completed_tasks'.tr(),
              value: stats?.completedTasksToday?.toString() ?? '—',
              iconColor: AppColors.green200,
              onTap: () => context.pushNamed(
                Routes.supervisorTaskListScreen,
                arguments: {
                  'title': 'supervisor_dashboard.completed_tasks'.tr(),
                  'accentColor': AppColors.green200,
                },
                rootNavigator: true,
              ),
            ),
            _StatCard(
              icon: Icons.access_time_outlined,
              label: 'supervisor_dashboard.delayed_tasks'.tr(),
              value: stats?.delayedTasks?.toString() ?? '—',
              iconColor: AppColors.amber200,
              onTap: () => context.pushNamed(
                Routes.supervisorTaskListScreen,
                arguments: {
                  'title': 'supervisor_dashboard.delayed_tasks'.tr(),
                  'accentColor': AppColors.amber200,
                },
                rootNavigator: true,
              ),
            ),
            _StatCard(
              icon: Icons.description_outlined,
              label: 'supervisor_dashboard.reports_today'.tr(),
              value: stats?.reportsToday?.toString() ?? '—',
              iconColor: AppColors.blue200,
              onTap: () =>
                  context.read<SupervisorBottomNavCubit>().jumpTo(1),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final numericValue = int.tryParse(value) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: rw(32),
                  height: rw(32),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(rr(8)),
                  ),
                  child: Icon(icon, color: iconColor, size: rf(16)),
                ),
                horizontalSpacing(8),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTextStyles.font12Light.copyWith(
                      color: cc.textHint,
                      letterSpacing: 0.6,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                value == '—'
                    ? Text(
                        '—',
                        style: AppTextStyles.font24ExtraBold.copyWith(
                          color: cc.textHint,
                          height: 1,
                        ),
                      )
                    : Text(value,
                            style: AppTextStyles.font24ExtraBold.copyWith(
                              color: cc.textPrimary,
                              height: 1,
                            ))
                        .animate(key: ValueKey('stat_$value'))
                        .custom(
                          duration: 400.ms,
                          curve: Curves.easeOut,
                          builder: (ctx, progress, child) => Text(
                            '${(progress * numericValue).round()}',
                            style: AppTextStyles.font24ExtraBold.copyWith(
                              color: cc.textPrimary,
                              height: 1,
                            ),
                          ),
                        ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: cc.textHint,
                  size: rf(18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: rw(32),
                height: rw(32),
                decoration: BoxDecoration(
                  color: cc.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(rr(8)),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(
                    duration: 1200.ms,
                    color: cc.border.withValues(alpha: 0.6),
                  ),
              horizontalSpacing(8),
              Expanded(
                child: Container(
                  height: rh(10),
                  decoration: BoxDecoration(
                    color: cc.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(rr(4)),
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(
                      duration: 1200.ms,
                      color: cc.border.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
          Container(
            width: rw(48),
            height: rh(24),
            decoration: BoxDecoration(
              color: cc.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(rr(6)),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 1200.ms,
                color: cc.border.withValues(alpha: 0.6),
              ),
        ],
      ),
    );
  }
}
