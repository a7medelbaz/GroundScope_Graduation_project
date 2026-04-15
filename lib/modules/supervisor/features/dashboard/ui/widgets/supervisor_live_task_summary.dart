import 'package:flutter/material.dart';
import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../../core/utils/spacing.dart';

class SupervisorLiveTaskSummary extends StatelessWidget {
  const SupervisorLiveTaskSummary({super.key});

  // TODO: replace with real data from supervisor cubit
  static const double _donePct = 0.70;
  static const double _inProgressPct = 0.20;
  static const double _delayPct = 0.10;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

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
          // Header
          Row(
            children: [
              Text(
                'Live Task Summary',
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
                      'LIVE UPDATES',
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

          // Stacked progress bar
          const _StackedProgressBar(
            done: _donePct,
            inProgress: _inProgressPct,
            delay: _delayPct,
          ),

          verticalSpacing(12),

          // Legend
          Row(
            children: [
              _LegendDot(
                color: AppColors.green200,
                label: '${(_donePct * 100).toInt()}% Done',
              ),
              horizontalSpacing(16),
              _LegendDot(
                color: AppColors.primary200,
                label: '${(_inProgressPct * 100).toInt()}% In-Prog',
              ),
              horizontalSpacing(16),
              _LegendDot(
                color: AppColors.amber200,
                label: '${(_delayPct * 100).toInt()}% Delay',
              ),
            ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(rr(6)),
      child: SizedBox(
        height: rh(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            return Row(
              children: [
                Container(
                  width: totalWidth * done,
                  color: AppColors.green200,
                ),
                Container(
                  width: totalWidth * inProgress,
                  color: AppColors.primary200,
                ),
                Container(
                  width: totalWidth * delay,
                  color: AppColors.amber200,
                ),
              ],
            );
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