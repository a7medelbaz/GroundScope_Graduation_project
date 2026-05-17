import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../../core/utils/spacing.dart';
import '../../logic/cubit/supervisor_dashboard_cubit.dart';

class SupervisorLiveTaskSummary extends StatelessWidget {
  const SupervisorLiveTaskSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocBuilder<SupervisorDashboardCubit, SupervisorDashboardState>(
      builder: (context, state) {
        final isLoading = state.status == DashboardStatus.loading;
        final summary = state.taskSummary;

        return Container(
          padding: EdgeInsets.all(rw(16)),
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
            children: [
              Row(
                children: [
                  Text(
                    'supervisor_dashboard.live_task_summary'.tr(),
                    style: AppTextStyles.font16SemiBold.copyWith(
                      color: cc.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(8),
                      vertical: rh(4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary200.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(rr(8)),
                      border: Border.all(
                        color: AppColors.primary200.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: rw(6),
                          height: rw(6),
                          decoration: const BoxDecoration(
                            color: AppColors.green200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        horizontalSpacing(5),
                        Text(
                          'supervisor_dashboard.live_updates'.tr(),
                          style: AppTextStyles.font12SemiBold.copyWith(
                            color: AppColors.primary200,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              verticalSpacing(16),
              if (isLoading && summary == null)
                _ProgressBarSkeleton()
              else if (summary == null || summary.isEmpty)
                _EmptyState()
              else ...[
                _StackedProgressBar(
                  done: summary.donePct,
                  inProgress: summary.inProgressPct,
                  delay: summary.delayedPct,
                ),
                verticalSpacing(12),
                Row(
                  children: [
                    _LegendDot(
                      color: AppColors.green200,
                      label:
                          '${(summary.donePct * 100).toInt()}% ${'supervisor_dashboard.done'.tr()}',
                    ),
                    horizontalSpacing(16),
                    _LegendDot(
                      color: AppColors.primary200,
                      label:
                          '${(summary.inProgressPct * 100).toInt()}% ${'supervisor_dashboard.in_progress'.tr()}',
                    ),
                    horizontalSpacing(16),
                    _LegendDot(
                      color: AppColors.amber200,
                      label:
                          '${(summary.delayedPct * 100).toInt()}% ${'supervisor_dashboard.delayed'.tr()}',
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBarSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(rr(6)),
      child: Container(
        height: rh(12),
        color: cc.border.withValues(alpha: 0.3),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: cc.border.withValues(alpha: 0.6),
        );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: rf(18), color: cc.textHint),
          horizontalSpacing(8),
          Text(
            'supervisor_dashboard.no_tasks_today'.tr(),
            style: AppTextStyles.font14SemiBold.copyWith(color: cc.textHint),
          ),
        ],
      ),
    );
  }
}

class _StackedProgressBar extends StatelessWidget {
  const _StackedProgressBar({
    required this.done,
    required this.inProgress,
    required this.delay,
  });

  final double done;
  final double inProgress;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isArabic;

    return ClipRRect(
      borderRadius: BorderRadius.circular(rr(6)),
      child: SizedBox(
        height: rh(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final segments = isRtl
                ? [
                    Container(
                      width: totalWidth * delay,
                      color: AppColors.amber200,
                    ),
                    Container(
                      width: totalWidth * inProgress,
                      color: AppColors.primary200,
                    ),
                    Container(width: totalWidth * done, color: AppColors.green200),
                  ]
                : [
                    Container(width: totalWidth * done, color: AppColors.green200),
                    Container(
                      width: totalWidth * inProgress,
                      color: AppColors.primary200,
                    ),
                    Container(width: totalWidth * delay, color: AppColors.amber200),
                  ];
            return Row(children: segments);
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Row(
      children: [
        Container(
          width: rw(8),
          height: rw(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        horizontalSpacing(5),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.font12Light.copyWith(
            color: cc.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
