import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class FlightStatusBadge extends StatelessWidget {
  const FlightStatusBadge({super.key, required this.status});

  final FlightStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      FlightStatus.scheduled => (AppColors.blue200, 'scheduled'.tr()),
      FlightStatus.landed => (AppColors.green200, 'landed'.tr()),
      FlightStatus.inService => (AppColors.amber200, 'in_service'.tr()),
      FlightStatus.ready => (AppColors.primary200, 'ready'.tr()),
      FlightStatus.departed => (AppColors.grey400, 'departed'.tr()),
      FlightStatus.cancelled => (AppColors.red200, 'cancelled'.tr()),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: AppTextStyles.font12Light.copyWith(color: color)),
    );
  }
}
