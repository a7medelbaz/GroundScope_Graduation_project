import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UnitStatusBadge extends StatelessWidget {
  const UnitStatusBadge({super.key, required this.status});

  final UnitStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
      ),
      child: Text(
        status.label.tr(),
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }

  static Color _color(UnitStatus status) => switch (status) {
        UnitStatus.available => AppColors.green200,
        UnitStatus.busy => AppColors.amber200,
        UnitStatus.offline => AppColors.grey400,
        UnitStatus.maintenance => AppColors.red200,
      };

  static Color colorFor(UnitStatus status) => _color(status);
}
