import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/flight_status_checker.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/modules/admin/features/flights/logic/cubit/flights_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_status_badge.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/stand_assignment_sheet.dart';

class FlightDetailScreen extends StatelessWidget {
  const FlightDetailScreen({super.key, required this.flight});

  final FlightModel flight;

  void _openAssignmentSheet(BuildContext context, FlightModel flight) {
    final cubit = context.read<FlightsListCubit>();
    showStandAssignmentSheet(
      context: context,
      flight: flight,
      cubit: cubit,
      standsFuture: cubit.getAvailableStands(flight),
      onAssign: (stand) => cubit.assignStand(flight: flight, stand: stand),
    );
  }

  Future<void> _removeStand(BuildContext context, FlightModel flight) async {
    final cubit = context.read<FlightsListCubit>();
    final success = await cubit.unassignStand(flight);
    if (!context.mounted) return;
    if (success) {
      context.showSuccessSnackBar('stand_removed_success'.tr());
    }
  }

  Future<void> _changeStatus(
    BuildContext context,
    FlightModel flight,
    FlightStatus status,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('change_status'.tr()),
        content: Text(
          'confirm_flight_status_change'.tr(
            namedArgs: {'status': status.label},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text('app_dialogs.confirm'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final cubit   = context.read<FlightsListCubit>();
    final success = await cubit.updateStatus(flight, status);
    if (!context.mounted) return;
    if (success) {
      context.showSuccessSnackBar('status_updated'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      body: SafeArea(
        child: BlocConsumer<FlightsListCubit, FlightsListState>(
          listenWhen: (previous, current) =>
              current.error != null && previous.error != current.error,
          listener: (context, state) =>
              context.showErrorSnackBar(state.error!.messageKey),
          builder: (context, state) {
            final current = state.all.firstWhere(
              (f) => f.id == flight.id,
              orElse: () => flight,
            );

            return Column(
              children: [
                _buildAppBar(context, current),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(flight: current)
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms),
                        verticalSpacing(24),
                        _SectionCard(
                          title: 'flight_details'.tr(),
                          delay: 80.ms,
                          children: [
                            _DetailRow(
                              label: 'aircraft'.tr(),
                              value: current.aircraftType != null
                                  ? '${current.aircraftType} (${current.aircraftRegistration ?? '—'})'
                                  : '—',
                            ),
                            _DetailRow(
                              label: 'scheduled_arrival'.tr(),
                              value: current.scheduledArrival.formattedTime,
                            ),
                            _DetailRow(
                              label: 'scheduled_departure'.tr(),
                              value: current.scheduledDeparture?.formattedTime ?? '—',
                            ),
                            _DetailRow(
                              label: 'estimated_arrival'.tr(),
                              value: current.estimatedArrival?.formattedTime ?? '—',
                            ),
                            _DetailRow(
                              label: 'flight_type'.tr(),
                              value: current.flightType == FlightType.departure
                                  ? 'departure'.tr()
                                  : 'arrival'.tr(),
                            ),
                            if (current.depTerminal != null || current.depGate != null)
                              _DetailRow(
                                label: 'departure_terminal_gate'.tr(),
                                value: '${current.depTerminal ?? '—'} / ${current.depGate ?? '—'}',
                              ),
                            if (current.arrTerminal != null || current.arrGate != null)
                              _DetailRow(
                                label: 'arrival_terminal_gate'.tr(),
                                value: '${current.arrTerminal ?? '—'} / ${current.arrGate ?? '—'}',
                              ),
                            if (current.delayMinutes != null && current.delayMinutes! > 0)
                              _DetailRow(
                                label: 'delay'.tr(),
                                value: 'delay_minutes_value'.tr(namedArgs: {'count': '${current.delayMinutes}'}),
                              ),
                          ],
                        ),
                        verticalSpacing(20),
                        _SectionCard(
                          title: 'stand_assignment'.tr(),
                          delay: 140.ms,
                          children: [
                            if (current.standId == null)
                              _NoStandCard(
                                onAssign: () => _openAssignmentSheet(context, current),
                              )
                            else
                              _AssignedStandCard(
                                flight: current,
                                onChange: () => _openAssignmentSheet(context, current),
                                onRemove: () => _removeStand(context, current),
                              ),
                          ],
                        ),
                        verticalSpacing(20),
                        _SectionCard(
                          title: 'status'.tr(),
                          delay: 200.ms,
                          children: [
                            if (current.status == FlightStatus.departed ||
                                current.status == FlightStatus.cancelled)
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: rw(16),
                                    color: context.customColors.textHint,
                                  ),
                                  horizontalSpacing(6),
                                  Text(
                                    current.status.label,
                                    style: AppTextStyles.font12SemiBold.copyWith(
                                      color: context.customColors.textHint,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Wrap(
                                spacing: rw(8),
                                runSpacing: rh(8),
                                children: [
                                  // Current status chip (non-interactive)
                                  ChoiceChip(
                                    label: Text(current.status.label),
                                    selected: true,
                                    onSelected: null,
                                    selectedColor: AppColors.blue200,
                                    labelStyle: AppTextStyles.font12SemiBold
                                        .copyWith(color: AppColors.white),
                                    backgroundColor:
                                        context.customColors.background,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(rr(20)),
                                      side: const BorderSide(
                                          color: AppColors.blue200),
                                    ),
                                  ),
                                  // Forward-only allowed next statuses
                                  ...FlightStatusChecker.allowedNextStatuses(
                                          current.status)
                                      .map((status) => ChoiceChip(
                                            label: Text(status.label),
                                            selected: false,
                                            onSelected: (_) => _changeStatus(
                                                context, current, status),
                                            selectedColor: AppColors.blue200,
                                            labelStyle: AppTextStyles
                                                .font12SemiBold
                                                .copyWith(
                                              color: context
                                                  .customColors.textSecondary,
                                            ),
                                            backgroundColor:
                                                context.customColors.background,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(rr(20)),
                                              side: BorderSide(
                                                color:
                                                    context.customColors.border,
                                              ),
                                            ),
                                          )),
                                ],
                              ),
                          ],
                        ),
                        verticalSpacing(20),
                        _SectionCard(
                          title: 'request_services'.tr(),
                          delay: 260.ms,
                          children: [
                            if (FlightStatusChecker.canRequestServices(current))
                              SizedBox(
                                width: double.infinity,
                                height: rh(46),
                                child: ElevatedButton.icon(
                                  onPressed: () => context.pushNamed(
                                    Routes.adminFlightServiceRequestScreen,
                                    arguments: {'flight': current},
                                  ),
                                  icon: const Icon(
                                      Icons.miscellaneous_services_outlined),
                                  label: Text('request_services'.tr()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary200,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(rr(14)),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: rw(16),
                                    color: context.customColors.textHint,
                                  ),
                                  horizontalSpacing(8),
                                  Text(
                                    'services_already_assigned'.tr(),
                                    style: AppTextStyles.font12Light.copyWith(
                                      color: context.customColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        verticalSpacing(16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, FlightModel flight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(8)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: context.pop,
          ),
          Expanded(
            child: Text(
              flight.flightNumber,
              textAlign: TextAlign.center,
              style: AppTextStyles.font18SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.flight});

  final FlightModel flight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                flight.airline,
                style: AppTextStyles.font18SemiBold.copyWith(
                  color: context.customColors.textPrimary,
                ),
              ),
              verticalSpacing(4),
              Text(
                '${flight.origin} → ${flight.destination}',
                style: AppTextStyles.font14Light.copyWith(
                  color: context.customColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        FlightStatusBadge(status: flight.status),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.delay = Duration.zero,
  });

  final String title;
  final List<Widget> children;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.font12SemiBold.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          verticalSpacing(12),
          ...children,
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.font12SemiBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoStandCard extends StatelessWidget {
  const _NoStandCard({required this.onAssign});

  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, size: rw(18), color: AppColors.amber200),
            horizontalSpacing(8),
            Text(
              'no_stand_assigned'.tr(),
              style: AppTextStyles.font12SemiBold.copyWith(color: AppColors.amber200),
            ),
          ],
        ),
        verticalSpacing(12),
        SizedBox(
          width: double.infinity,
          height: rh(46),
          child: ElevatedButton(
            onPressed: onAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue200,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rr(14)),
              ),
            ),
            child: Text('assign_stand'.tr()),
          ),
        ),
      ],
    );
  }
}

class _AssignedStandCard extends StatelessWidget {
  const _AssignedStandCard({
    required this.flight,
    required this.onChange,
    required this.onRemove,
  });

  final FlightModel flight;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.local_parking_outlined, size: rw(18), color: AppColors.blue200),
            horizontalSpacing(8),
            Text(
              '${flight.stand?.code ?? ''} — ${flight.stand?.terminal ?? ''}',
              style: AppTextStyles.font14SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
            ),
          ],
        ),
        verticalSpacing(12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onChange,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: rh(12)),
                  side: BorderSide(color: context.customColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rr(14)),
                  ),
                ),
                child: Text('change_stand'.tr()),
              ),
            ),
            horizontalSpacing(12),
            Expanded(
              child: OutlinedButton(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: rh(12)),
                  side: BorderSide(color: AppColors.red200.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rr(14)),
                  ),
                ),
                child: Text('remove_stand'.tr(), style: const TextStyle(color: AppColors.red200)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
