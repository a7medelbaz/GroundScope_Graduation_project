import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/info_card.dart';
import 'package:ground_scope/core/widgets/info_row_data.dart';

import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';

class ProfileUnitInfoSection extends StatelessWidget {
  const ProfileUnitInfoSection({super.key, required this.unit});

  final UnitProfileModel unit;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Card(
      elevation: 1,
      shadowColor: cc.border.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rr(16)),
        side: BorderSide(color: cc.border.withValues(alpha: 0.4)),
      ),
      color: cc.surface,
      child: Padding(
        padding: EdgeInsets.all(rw(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + Name + Service Type + Status ─────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: rr(36),
                    backgroundColor: AppColors.primary200.withValues(alpha: 0.12),
                    child: Text(
                      unit.name.isNotEmpty ? unit.name[0].toUpperCase() : '?',
                      style: AppTextStyles.font22ExtraBold.copyWith(
                        color: AppColors.primary300,
                      ),
                    ),
                  ),
                  verticalSpacing(12),
                  Text(
                    unit.name,
                    style: AppTextStyles.font18SemiBold.copyWith(
                      color: cc.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacing(4),
                  Text(
                    unit.serviceTypeName,
                    style: AppTextStyles.font14Light.copyWith(
                      color: cc.textSecondary,
                    ),
                  ),
                  verticalSpacing(10),
                  _StatusBadge(status: unit.status),
                ],
              ),
            ),

            // ── Shift Times ───────────────────────────────────────────
            if (unit.shiftStartTime != null || unit.shiftEndTime != null) ...[
              verticalSpacing(16),
              InfoCard(
                rows: [
                  if (unit.shiftStartTime != null)
                    InfoRowData(
                      icon: Icons.schedule_rounded,
                      label: 'worker_profile.shift_start'.tr(),
                      value: unit.shiftStartTime!,
                    ),
                  if (unit.shiftEndTime != null)
                    InfoRowData(
                      icon: Icons.schedule_outlined,
                      label: 'worker_profile.shift_end'.tr(),
                      value: unit.shiftEndTime!,
                    ),
                ],
              ),
            ],

            // ── Compatible Aircraft ───────────────────────────────────
            verticalSpacing(16),
            Text(
              'worker_profile.compatible_aircraft'.tr(),
              style: AppTextStyles.font14SemiBold.copyWith(
                color: cc.textPrimary,
              ),
            ),
            verticalSpacing(8),
            unit.compatibleAircraft.isEmpty
                ? Text(
                    'worker_profile.no_aircraft'.tr(),
                    style: AppTextStyles.font14Light.copyWith(
                      color: cc.textHint,
                    ),
                  )
                : Wrap(
                    spacing: rw(8),
                    runSpacing: rh(8),
                    children: unit.compatibleAircraft
                        .map(
                          (aircraft) => Chip(
                            label: Text(
                              aircraft,
                              style: AppTextStyles.font12SemiBold.copyWith(
                                color: AppColors.primary300,
                              ),
                            ),
                            backgroundColor:
                                AppColors.primary200.withValues(alpha: 0.08),
                            side: BorderSide(
                              color: AppColors.primary200.withValues(alpha: 0.25),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: rw(4)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final UnitStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      UnitStatus.available => (
          AppColors.green200,
          'worker_profile.available'.tr(),
        ),
      UnitStatus.busy => (AppColors.amber200, 'worker_profile.busy'.tr()),
      UnitStatus.offline => (AppColors.grey400, 'worker_profile.offline'.tr()),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: rw(8),
          height: rw(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        horizontalSpacing(5),
        Text(
          label,
          style: AppTextStyles.font12SemiBold.copyWith(color: color),
        ),
      ],
    );
  }
}
