import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

void showStandUsageSheet({
  required BuildContext context,
  required StandModel model,
  required Future<List<FlightModel>> flightsFuture,
  required VoidCallback onEdit,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StandUsageSheet(
      model: model,
      flightsFuture: flightsFuture,
      onEdit: onEdit,
    ),
  );
}

class _StandUsageSheet extends StatelessWidget {
  const _StandUsageSheet({
    required this.model,
    required this.flightsFuture,
    required this.onEdit,
  });

  final StandModel model;
  final Future<List<FlightModel>> flightsFuture;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(24))),
      ),
      padding: EdgeInsets.fromLTRB(rw(20), rh(12), rw(20), rh(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: rw(40),
              height: rh(4),
              decoration: BoxDecoration(
                color: context.customColors.border,
                borderRadius: BorderRadius.circular(rr(2)),
              ),
            ),
          ),
          verticalSpacing(20),
          _SheetHeader(model: model),
          verticalSpacing(20),
          Divider(color: context.customColors.divider),
          verticalSpacing(16),
          Text(
            'scheduled_flights'.tr(),
            style: AppTextStyles.font14SemiBold.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          verticalSpacing(12),
          FutureBuilder<List<FlightModel>>(
            future: flightsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const _StandFlightsShimmer();
              }
              final flights = snapshot.data!;
              if (flights.isEmpty) {
                return const _StandNoFlightsState();
              }
              return Column(
                children:
                    flights.map((f) => _StandFlightRow(flight: f)).toList(),
              );
            },
          ),
          verticalSpacing(20),
          Text(
            'stand_compatible_aircraft'.tr(),
            style: AppTextStyles.font14SemiBold.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          verticalSpacing(12),
          model.compatibleAircraft.isEmpty
              ? Text(
                  'no_aircraft_assigned'.tr(),
                  style: AppTextStyles.font12Light.copyWith(
                    color: context.customColors.textSecondary,
                  ),
                )
              : Wrap(
                  spacing: rw(8),
                  runSpacing: rh(8),
                  children: model.compatibleAircraft
                      .map(
                        (ac) => Chip(
                          label: Text(
                            ac,
                            style: AppTextStyles.font12SemiBold.copyWith(
                              color: AppColors.blue200,
                            ),
                          ),
                          backgroundColor:
                              AppColors.blue200.withValues(alpha: 0.1),
                          side: BorderSide(
                              color: AppColors.blue200.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rr(20)),
                          ),
                        ),
                      )
                      .toList(),
                ),
          verticalSpacing(24),
          Divider(color: context.customColors.divider),
          verticalSpacing(16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    onEdit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue200,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: rh(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rr(14)),
                    ),
                  ),
                  child: Text('edit'.tr(), style: AppTextStyles.font14SemiBold),
                ),
              ),
              horizontalSpacing(12),
              Expanded(
                child: OutlinedButton(
                  onPressed: context.pop,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: rh(14)),
                    side: BorderSide(color: context.customColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rr(14)),
                    ),
                  ),
                  child: Text(
                    'close'.tr(),
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: context.customColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.model});

  final StandModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: rw(48),
          height: rw(48),
          decoration: BoxDecoration(
            color: AppColors.blue200.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(rr(12)),
          ),
          child: Center(
            child: Text(
              model.code,
              style: AppTextStyles.font14ExtraBold.copyWith(
                color: AppColors.blue200,
              ),
            ),
          ),
        ),
        horizontalSpacing(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.code,
              style: AppTextStyles.font18SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
            ),
            verticalSpacing(2),
            Text(
              model.terminal,
              style: AppTextStyles.font12Light.copyWith(
                color: context.customColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StandFlightRow extends StatelessWidget {
  const _StandFlightRow({required this.flight});

  final FlightModel flight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(8)),
      padding: EdgeInsets.all(rw(14)),
      decoration: BoxDecoration(
        color: context.customColors.background,
        borderRadius: BorderRadius.circular(rr(12)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: rw(36),
            height: rw(36),
            decoration: BoxDecoration(
              color: AppColors.blue200.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flight_outlined,
              size: rw(18),
              color: AppColors.blue200,
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${flight.flightNumber}  ·  ${flight.airline}',
                  style: AppTextStyles.font14SemiBold.copyWith(
                    color: context.customColors.textPrimary,
                  ),
                ),
                verticalSpacing(4),
                Text(
                  '${flight.scheduledArrival.formattedTime}'
                  ' → '
                  '${flight.scheduledDeparture?.formattedTime ?? '—'}',
                  style: AppTextStyles.font12Light.copyWith(
                    color: context.customColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _FlightStatusBadge(status: flight.status),
        ],
      ),
    );
  }
}

class _FlightStatusBadge extends StatelessWidget {
  const _FlightStatusBadge({required this.status});

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
      child: Text(
        label,
        style: AppTextStyles.font12Light.copyWith(color: color),
      ),
    );
  }
}

class _StandFlightsShimmer extends StatelessWidget {
  const _StandFlightsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: EdgeInsets.only(bottom: rh(8)),
          height: rh(64),
          decoration: BoxDecoration(
            color: context.customColors.surfaceVariant,
            borderRadius: BorderRadius.circular(rr(12)),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1500.ms, color: context.customColors.surface),
      ),
    );
  }
}

class _StandNoFlightsState extends StatelessWidget {
  const _StandNoFlightsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(16)),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.flight_outlined,
              size: rw(32),
              color: context.customColors.iconSecondary,
            ),
            verticalSpacing(8),
            Text(
              'no_flights_for_stand'.tr(),
              style: AppTextStyles.font12Light.copyWith(
                color: context.customColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
