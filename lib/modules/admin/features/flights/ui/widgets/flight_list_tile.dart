import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_status_badge.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_warning_badge.dart';

class FlightListTile extends StatelessWidget {
  const FlightListTile({
    super.key,
    required this.flight,
    required this.isWarning,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  final FlightModel flight;
  final bool isWarning;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final isDeparture = flight.flightType == FlightType.departure;

    return Container(
          margin: EdgeInsets.only(bottom: rh(8)),
          decoration: BoxDecoration(
            color: context.customColors.surface,
            borderRadius: BorderRadius.circular(rr(16)),
            border: Border.all(
              color: isWarning
                  ? AppColors.amber200.withValues(alpha: 0.5)
                  : context.customColors.border,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(rr(16)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWarning) ...[
                    const FlightWarningBadge(),
                    horizontalSpacing(8),
                  ],
                  Container(
                    width: rw(44),
                    height: rh(44),
                    decoration: BoxDecoration(
                      color: AppColors.blue200.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(rr(12)),
                    ),
                    child: Center(
                      child: Text(
                        flight.airline.isNotEmpty
                            ? flight.airline.substring(0, 1).toUpperCase()
                            : '?',
                        style: AppTextStyles.font14ExtraBold.copyWith(
                          color: AppColors.blue200,
                        ),
                      ),
                    ),
                  ),
                  horizontalSpacing(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              flight.flightNumber,
                              style: AppTextStyles.font14SemiBold.copyWith(
                                color: context.customColors.textPrimary,
                              ),
                            ),
                            horizontalSpacing(6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: rw(6),
                                vertical: rh(2),
                              ),
                              decoration: BoxDecoration(
                                color: (isDeparture
                                        ? AppColors.amber200
                                        : AppColors.blue200)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(rr(6)),
                              ),
                              child: Text(
                                isDeparture ? 'dep'.tr() : 'arr'.tr(),
                                style: AppTextStyles.font12SemiBold.copyWith(
                                  color: isDeparture
                                      ? AppColors.amber200
                                      : AppColors.blue200,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(4),
                        Text(
                          '${flight.origin} → ${flight.destination}',
                          style: AppTextStyles.font12Light.copyWith(
                            color: context.customColors.textSecondary,
                          ),
                        ),
                        verticalSpacing(4),
                        Text(
                          flight.scheduledArrival.formattedTime,
                          style: AppTextStyles.font12Light.copyWith(
                            color: context.customColors.textSecondary,
                          ),
                        ),
                        verticalSpacing(4),
                        Text(
                          flight.standId != null
                              ? '${'stands'.tr()}: ${flight.stand?.code ?? ''}'
                              : 'no_stand_assigned'.tr(),
                          style: AppTextStyles.font12SemiBold.copyWith(
                            color: flight.standId != null
                                ? context.customColors.textSecondary
                                : AppColors.red200,
                          ),
                        ),
                      ],
                    ),
                  ),
                  horizontalSpacing(8),
                  FlightStatusBadge(status: flight.status),
                ],
              ),
            ),
          ),
        )
        .animate(delay: animationDelay)
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.1, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}
