import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'unit_detail_bottom_sheet.dart';

class UnitStatusCard extends StatelessWidget {
  const UnitStatusCard({super.key, required this.unit});

  final UnitModel unit;

  Color _statusColor(BuildContext context) => switch (unit.status) {
        'available' => AppColors.green200,
        'busy' => AppColors.primary200,
        _ => context.customColors.textDisabled,
      };

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final statusColor = _statusColor(context);

    return GestureDetector(
      onTap: () => _openDetailSheet(context),
      child: Container(
        margin: EdgeInsets.only(bottom: rh(10)),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(rr(14)),
          border: Border.all(color: cc.border.withValues(alpha: 0.6)),
        ),
        padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
        child: Row(
          children: [
            // Icon container
            Container(
              width: rw(42),
              height: rw(42),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(rr(12)),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: rf(20),
                color: statusColor,
              ),
            ),
            horizontalSpacing(12),
            // Name + shift + task line
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.name,
                    style: AppTextStyles.font14ExtraBold
                        .copyWith(color: cc.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpacing(2),
                  Text(
                    unit.shiftLabel,
                    style: AppTextStyles.font12Light
                        .copyWith(color: cc.textHint),
                  ),
                  verticalSpacing(2),
                  _TaskLine(status: unit.status, cc: cc),
                ],
              ),
            ),
            horizontalSpacing(8),
            // Status badge
            _StatusBadge(status: unit.status, color: statusColor),
          ],
        ),
      ),
    );
  }

  void _openDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnitDetailBottomSheet(unit: unit),
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.status, required this.cc});

  final String status;
  final dynamic cc;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      'busy' => Text(
          'no_active_task'.tr(),
          style: AppTextStyles.font12Light
              .copyWith(color: AppColors.primary200),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      'offline' => Text(
          'off_shift'.tr(),
          style: AppTextStyles.font12Light
              .copyWith(color: context.customColors.textDisabled),
        ),
      _ => Text(
          'no_active_task'.tr(),
          style: AppTextStyles.font12Light
              .copyWith(color: context.customColors.textHint),
        ),
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final String status;
  final Color color;

  String get _label => switch (status) {
        'available' => 'filter_available',
        'busy' => 'filter_busy',
        _ => 'filter_offline',
      };

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
        _label.tr(),
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }
}
