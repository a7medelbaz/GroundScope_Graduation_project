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
    this.serviceCount,
  });

  final FlightModel flight;
  final bool isWarning;
  final VoidCallback onTap;
  final Duration animationDelay;
  final int? serviceCount;

  Color _accentColor(BuildContext context) => switch (flight.status) {
    FlightStatus.landed => AppColors.amber200,
    FlightStatus.inService => AppColors.blue200,
    FlightStatus.ready => AppColors.green200,
    FlightStatus.departed => context.customColors.textHint,
    FlightStatus.cancelled => context.customColors.border,
    _ => Colors.transparent,
  };

  String _statusHint() => switch (flight.status) {
    FlightStatus.scheduled => 'status_hint_scheduled'.tr(),
    FlightStatus.landed => 'status_hint_landed'.tr(),
    FlightStatus.inService => 'status_hint_in_service'.tr(),
    FlightStatus.ready => 'status_hint_ready'.tr(),
    FlightStatus.departed => 'status_hint_departed'.tr(),
    FlightStatus.cancelled => 'status_hint_cancelled'.tr(),
  };

  Color _statusHintColor(BuildContext context) => switch (flight.status) {
    FlightStatus.scheduled => AppColors.primary200,
    FlightStatus.landed => AppColors.amber200,
    FlightStatus.inService => AppColors.blue200,
    FlightStatus.ready => AppColors.green200,
    FlightStatus.departed => context.customColors.textHint,
    FlightStatus.cancelled => context.customColors.textDisabled,
  };

  bool get _isDimmed =>
      flight.status == FlightStatus.departed ||
      flight.status == FlightStatus.cancelled;

  bool get _showServiceBadge =>
      flight.status == FlightStatus.scheduled ||
      flight.status == FlightStatus.landed ||
      flight.status == FlightStatus.inService;

  @override
  Widget build(BuildContext context) {
    final isDeparture = flight.flightType == FlightType.departure;
    final accentColor = _accentColor(context);
    final showAccent = accentColor != Colors.transparent;

    return Opacity(
      opacity: _isDimmed ? 0.6 : 1.0,
      child:
          Container(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(rr(16)),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showAccent)
                          Container(width: rw(4), color: accentColor),
                        Expanded(
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(rr(16)),
                              left: showAccent
                                  ? Radius.zero
                                  : Radius.circular(rr(16)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: rw(12),
                                vertical: rh(14),
                              ),
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
                                      color: AppColors.blue200.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        rr(12),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        flight.airline.isNotEmpty
                                            ? flight.airline
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                            : '?',
                                        style: AppTextStyles.font14ExtraBold
                                            .copyWith(color: AppColors.blue200),
                                      ),
                                    ),
                                  ),
                                  horizontalSpacing(12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              flight.flightNumber,
                                              style: AppTextStyles
                                                  .font14SemiBold
                                                  .copyWith(
                                                    color: context
                                                        .customColors
                                                        .textPrimary,
                                                    decoration:
                                                        flight.status ==
                                                            FlightStatus
                                                                .cancelled
                                                        ? TextDecoration
                                                              .lineThrough
                                                        : null,
                                                  ),
                                            ),
                                            horizontalSpacing(6),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: rw(6),
                                                vertical: rh(2),
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (isDeparture
                                                            ? AppColors.amber200
                                                            : AppColors.blue200)
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      rr(6),
                                                    ),
                                              ),
                                              child: Text(
                                                isDeparture
                                                    ? 'dep'.tr()
                                                    : 'arr'.tr(),
                                                style: AppTextStyles
                                                    .font12SemiBold
                                                    .copyWith(
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
                                          style: AppTextStyles.font12Light
                                              .copyWith(
                                                color: context
                                                    .customColors
                                                    .textSecondary,
                                              ),
                                        ),
                                        verticalSpacing(4),
                                        Text(
                                          flight.scheduledArrival.formattedTime,
                                          style: AppTextStyles.font12Light
                                              .copyWith(
                                                color: context
                                                    .customColors
                                                    .textSecondary,
                                              ),
                                        ),
                                        verticalSpacing(4),
                                        Text(
                                          flight.standId != null
                                              ? '${'stands'.tr()}: ${flight.stand?.code ?? ''}'
                                              : 'no_stand_assigned'.tr(),
                                          style: AppTextStyles.font12SemiBold
                                              .copyWith(
                                                color: flight.standId != null
                                                    ? context
                                                          .customColors
                                                          .textSecondary
                                                    : AppColors.red200,
                                              ),
                                        ),
                                        verticalSpacing(6),
                                        Row(
                                          children: [
                                            Text(
                                              _statusHint(),
                                              style: AppTextStyles.font12Light
                                                  .copyWith(
                                                    color: _statusHintColor(
                                                      context,
                                                    ),
                                                  ),
                                            ),
                                            if (_showServiceBadge &&
                                                serviceCount != null) ...[
                                              const Spacer(),
                                              _ServiceCountBadge(
                                                count: serviceCount!,
                                              ),
                                            ],
                                          ],
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
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate(delay: animationDelay)
              .fadeIn(duration: 250.ms)
              .slideY(
                begin: 0.1,
                end: 0,
                duration: 250.ms,
                curve: Curves.easeOut,
              ),
    );
  }
}

class _ServiceCountBadge extends StatelessWidget {
  const _ServiceCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final hasServices = count > 0;
    final color = hasServices
        ? AppColors.primary200
        : context.customColors.textHint;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(2)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rr(10)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$count services',
        style: AppTextStyles.font12Light.copyWith(color: color),
      ),
    );
  }
}
