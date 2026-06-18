import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ServiceRequestStatusBadge extends StatelessWidget {
  const ServiceRequestStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'pending'     => (AppColors.amber200,   'request_status_pending'.tr()),
      'assigned'    => (AppColors.blue200,    'request_status_assigned'.tr()),
      'in_progress' => (AppColors.primary200, 'request_status_in_progress'.tr()),
      'completed'   => (AppColors.green200,   'request_status_completed'.tr()),
      'cancelled'   => (AppColors.grey400,    'request_status_cancelled'.tr()),
      _             => (AppColors.grey400,    status),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.font12Light.copyWith(color: color),
      ),
    );
  }
}
