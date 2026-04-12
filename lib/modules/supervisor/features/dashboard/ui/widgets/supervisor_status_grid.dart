import 'package:flutter/material.dart';
import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../../core/utils/spacing.dart';

class SupervisorStatsGrid extends StatelessWidget {
  const SupervisorStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: rw(12),
      mainAxisSpacing: rh(12),
      childAspectRatio: 1.55,
      children: const [
        _StatCard(
          icon: Icons.groups_outlined,
          label: 'Active Units',
          value: '4',
          iconColor: AppColors.primary200,
        ),
        _StatCard(
          icon: Icons.check_circle_outline,
          label: 'Completed Tasks',
          value: '128',
          iconColor: AppColors.green200,
        ),
        _StatCard(
          icon: Icons.access_time_outlined,
          label: 'Delayed Tasks',
          value: '3',
          iconColor: AppColors.amber200,
        ),
        _StatCard(
          icon: Icons.description_outlined,
          label: 'Reports Today',
          value: '1',
          iconColor: AppColors.blue200,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

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
          // Icon + label row
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
          // Value
          Text(
            value,
            style: AppTextStyles.font24ExtraBold.copyWith(
              color: cc.textPrimary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
