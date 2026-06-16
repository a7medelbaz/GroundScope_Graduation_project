import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class FlightEmptyState extends StatelessWidget {
  const FlightEmptyState({super.key, required this.onFetch});

  final VoidCallback onFetch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(rw(20)),
              decoration: BoxDecoration(
                color: AppColors.blue200.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.flight_outlined, size: rw(64), color: AppColors.blue200),
            ),
            verticalSpacing(24),
            Text(
              'no_flights_found'.tr(),
              style: AppTextStyles.font16SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(8),
            Text(
              'no_flights_today'.tr(),
              style: AppTextStyles.font12Light.copyWith(
                color: context.customColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(28),
            ElevatedButton.icon(
              onPressed: onFetch,
              icon: const Icon(Icons.refresh),
              label: Text('fetch_today'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue200,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: rw(28), vertical: rh(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rr(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scaleXY(begin: 0.95, end: 1.0, duration: 300.ms, curve: Curves.easeOut);
  }
}
