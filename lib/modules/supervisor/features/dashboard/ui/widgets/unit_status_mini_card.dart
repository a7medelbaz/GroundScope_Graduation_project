import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UnitStatusMiniCard extends StatelessWidget {
  const UnitStatusMiniCard({super.key, required this.unit});

  final UnitModel unit;

  Color _statusColor(BuildContext context) => switch (unit.status) {
        'available' => AppColors.green200,
        'busy' => AppColors.primary200,
        _ => context.customColors.textDisabled,
      };

  String _shiftLabel() {
    final start = unit.shiftStartTime;
    final end = unit.shiftEndTime;
    if (start == null || end == null) return '-';
    String fmt(String t) => t.length >= 5 ? t.substring(0, 5) : t;
    return '${fmt(start)} – ${fmt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final statusColor = _statusColor(context);

    return Container(
      margin: EdgeInsets.only(bottom: rh(10)),
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(14)),
        border: Border.all(color: cc.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: rw(42),
            height: rw(42),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(12)),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: statusColor,
              size: rf(20),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: AppTextStyles.font14ExtraBold
                      .copyWith(color: cc.textPrimary),
                ),
                verticalSpacing(2),
                Text(
                  _shiftLabel(),
                  style: AppTextStyles.font12Light.copyWith(color: cc.textHint),
                ),
                verticalSpacing(2),
                Text(
                  unit.status == 'busy'
                      ? 'active_tasks'.tr()
                      : unit.status == 'offline'
                          ? 'off_shift'.tr()
                          : 'no_active_task'.tr(),
                  style: AppTextStyles.font12Light.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
          horizontalSpacing(8),
          _StatusBadge(status: unit.status, color: statusColor),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(8)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }
}
