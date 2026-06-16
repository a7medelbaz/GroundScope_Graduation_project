import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class FlightWarningBadge extends StatelessWidget {
  const FlightWarningBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rw(4)),
      decoration: BoxDecoration(
        color: AppColors.amber200.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.warning_amber_rounded, size: rw(14), color: AppColors.amber200),
    );
  }
}
