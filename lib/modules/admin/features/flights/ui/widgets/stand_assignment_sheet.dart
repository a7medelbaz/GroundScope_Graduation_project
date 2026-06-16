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

void showStandAssignmentSheet({
  required BuildContext context,
  required FlightModel flight,
  required Future<List<StandModel>> standsFuture,
  required Future<bool> Function(StandModel stand) onAssign,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StandAssignmentSheet(
      flight: flight,
      standsFuture: standsFuture,
      onAssign: onAssign,
    ),
  );
}

class _StandAssignmentSheet extends StatefulWidget {
  const _StandAssignmentSheet({
    required this.flight,
    required this.standsFuture,
    required this.onAssign,
  });

  final FlightModel flight;
  final Future<List<StandModel>> standsFuture;
  final Future<bool> Function(StandModel stand) onAssign;

  @override
  State<_StandAssignmentSheet> createState() => _StandAssignmentSheetState();
}

class _StandAssignmentSheetState extends State<_StandAssignmentSheet> {
  bool _assigning = false;

  Future<void> _assign(StandModel stand) async {
    setState(() => _assigning = true);
    final success = await widget.onAssign(stand);
    if (!mounted) return;
    setState(() => _assigning = false);
    if (success) {
      context.pop();
      context.showSuccessSnackBar('stand_assigned_success'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
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
          Text(
            'available_stands'.tr(),
            style: AppTextStyles.font18SemiBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
          verticalSpacing(4),
          Text(
            '${flight.flightNumber} · ${flight.scheduledArrival.formattedTime}'
            ' → ${flight.scheduledDeparture?.formattedTime ?? '—'}',
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          verticalSpacing(16),
          Divider(color: context.customColors.divider),
          verticalSpacing(12),
          FutureBuilder<List<StandModel>>(
            future: widget.standsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const _StandsShimmer();
              }
              final stands = snapshot.data!;
              if (stands.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: rh(24)),
                  child: Center(
                    child: Text(
                      'no_stands_available'.tr(),
                      style: AppTextStyles.font12Light.copyWith(
                        color: context.customColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: rh(320)),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: stands.length,
                  separatorBuilder: (_, _) => verticalSpacing(8),
                  itemBuilder: (_, index) {
                    final stand = stands[index];
                    return _StandTile(
                      stand: stand,
                      enabled: !_assigning,
                      onTap: () => _assign(stand),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StandTile extends StatelessWidget {
  const _StandTile({
    required this.stand,
    required this.enabled,
    required this.onTap,
  });

  final StandModel stand;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(rr(12)),
        child: Container(
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
                  Icons.local_parking_outlined,
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
                      '${stand.code}   ${stand.terminal}',
                      style: AppTextStyles.font14SemiBold.copyWith(
                        color: context.customColors.textPrimary,
                      ),
                    ),
                    verticalSpacing(2),
                    Text(
                      stand.compatibleAircraft.isNotEmpty
                          ? stand.compatibleAircraft.join(', ')
                          : 'no_aircraft'.tr(),
                      style: AppTextStyles.font12Light.copyWith(
                        color: context.customColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandsShimmer extends StatelessWidget {
  const _StandsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
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
