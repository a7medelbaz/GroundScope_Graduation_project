import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../../core/utils/spacing.dart';
import '../../../../../../core/router/routes.dart';
import '../../logic/cubit/dashboard_cubit.dart';

class SupervisorStatsGrid extends StatelessWidget {
  const SupervisorStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final String activeUnits;
        final String completedTasks;
        final String delayedTasks;
        final String reportsToday;

        if (state is DashboardLoaded) {
          activeUnits = state.activeUnitsCount.toString();
          completedTasks = state.completedTasksCount.toString();
          delayedTasks = state.delayedTasksCount.toString();
          reportsToday = state.reportsTodayCount.toString();
        } else if (state is DashboardFailure) {
          activeUnits = '--';
          completedTasks = '--';
          delayedTasks = '--';
          reportsToday = '--';
        } else {
          activeUnits = '...';
          completedTasks = '...';
          delayedTasks = '...';
          reportsToday = '...';
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
              label: 'Active Units',
              value: activeUnits,
              iconColor: AppColors.primary200,
              onTap: () => context.pushNamed(
                Routes.supervisorUnitsScreen,
                rootNavigator: true,
              ),
            ),
            _StatCard(
              icon: Icons.check_circle_outline,
              label: 'Completed Tasks',
              value: completedTasks,
              iconColor: AppColors.green200,
              onTap: () => context.pushNamed(
                Routes.supervisorTaskListScreen,
                arguments: {
                  'title': 'Completed Tasks',
                  'accentColor': AppColors.green200,
                  'filterStatus': TaskStatus.completed,
                },
                rootNavigator: true,
              ),
            ),
            _StatCard(
              icon: Icons.access_time_outlined,
              label: 'Delayed Tasks',
              value: delayedTasks,
              iconColor: AppColors.amber200,
              onTap: () => context.pushNamed(
                Routes.supervisorTaskListScreen,
                arguments: {
                  'title': 'Delayed Tasks',
                  'accentColor': AppColors.amber200,
                  'filterStatus': TaskStatus.completed,
                },
                rootNavigator: true,
              ),
            ),
            _StatCard(
              icon: Icons.description_outlined,
              label: 'Reports Today',
              value: reportsToday,
              iconColor: AppColors.blue200,
              onTap: () => context.pushNamed(
                Routes.supervisorReportsScreen,
                rootNavigator: true,
              ),
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
                Text(
                  value,
                  style: AppTextStyles.font24ExtraBold.copyWith(
                    color: cc.textPrimary,
                    height: 1,
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
