import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/flights/logic/cubit/flight_import_cubit.dart';

void showFlightImportSheet({
  required BuildContext context,
  required FlightImportCubit cubit,
  required VoidCallback onImported,
}) {
  cubit.fetchPreview();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _FlightImportSheet(onImported: onImported),
    ),
  );
}

class _FlightImportSheet extends StatelessWidget {
  const _FlightImportSheet({required this.onImported});

  final VoidCallback onImported;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlightImportCubit, FlightImportState>(
      listener: (context, state) {
        if (state.status == FlightImportStatus.success) {
          onImported();
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) context.pop();
          });
        }
      },
      builder: (context, state) {
        return Container(
          constraints: BoxConstraints(maxHeight: context.screenHeight * 0.8),
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
                'fetch_flights'.tr(),
                style: AppTextStyles.font18SemiBold.copyWith(
                  color: context.customColors.textPrimary,
                ),
              ),
              verticalSpacing(16),
              Flexible(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FlightImportState state) {
    switch (state.status) {
      case FlightImportStatus.initial:
      case FlightImportStatus.fetching:
        return const _FetchingShimmer();
      case FlightImportStatus.preview:
      case FlightImportStatus.importing:
        return _PreviewList(state: state);
      case FlightImportStatus.success:
        return _SuccessState(count: state.importedCount);
      case FlightImportStatus.failure:
        return _FailureState(
          message: state.error?.messageKey ?? '',
          onRetry: () => context.read<FlightImportCubit>().fetchPreview(),
        );
    }
  }
}

class _FetchingShimmer extends StatelessWidget {
  const _FetchingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(24)),
      child: Column(
        children: [
          Text(
            'fetching_flights'.tr(),
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          verticalSpacing(16),
          ...List.generate(
            4,
            (_) => Container(
              margin: EdgeInsets.only(bottom: rh(8)),
              height: rh(48),
              decoration: BoxDecoration(
                color: context.customColors.surfaceVariant,
                borderRadius: BorderRadius.circular(rr(12)),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1500.ms, color: context.customColors.surface),
          ),
        ],
      ),
    );
  }
}

class _PreviewList extends StatelessWidget {
  const _PreviewList({required this.state});

  final FlightImportState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FlightImportCubit>();
    final importing = state.status == FlightImportStatus.importing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'flights_preview'.tr(
                namedArgs: {'count': '${state.preview.length}'},
              ),
              style: AppTextStyles.font14SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: importing ? null : cubit.toggleSelectAll,
              child: Text('select_all'.tr()),
            ),
          ],
        ),
        verticalSpacing(8),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: state.preview.length,
            separatorBuilder: (_, _) => verticalSpacing(6),
            itemBuilder: (_, index) {
              final flight = state.preview[index];
              final selected = state.selectedIds.contains(flight.externalId);
              return _PreviewTile(
                flight: flight,
                selected: selected,
                enabled: !importing,
                onTap: () => cubit.toggleSelection(flight.externalId ?? ''),
              );
            },
          ),
        ),
        verticalSpacing(16),
        SizedBox(
          width: double.infinity,
          height: rh(52),
          child: ElevatedButton(
            onPressed: importing || state.selectedIds.isEmpty
                ? null
                : cubit.importSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue200,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.blue200.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rr(14)),
              ),
            ),
            child: importing
                ? SizedBox(
                    width: rw(20),
                    height: rw(20),
                    child: const CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'import_selected'.tr(
                      namedArgs: {'count': '${state.selectedIds.length}'},
                    ),
                    style: AppTextStyles.font14SemiBold,
                  ),
          ),
        ),
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.flight,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final FlightModel flight;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDeparture = flight.flightType == FlightType.departure;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(rr(12)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(10)),
        decoration: BoxDecoration(
          color: context.customColors.background,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(color: context.customColors.border),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: enabled ? (_) => onTap() : null,
              activeColor: AppColors.blue200,
            ),
            Expanded(
              child: Text(
                '${flight.flightNumber}  ${flight.airline}  '
                '${flight.origin}→${flight.destination}  '
                '${flight.scheduledArrival.formattedTime}'
                ' ${isDeparture ? 'dep'.tr() : 'arr'.tr()}',
                style: AppTextStyles.font12Light.copyWith(
                  color: context.customColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(32)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: rw(56),
              color: AppColors.green200,
            ),
            verticalSpacing(12),
            Text(
              'import_success'.tr(namedArgs: {'count': '$count'}),
              style: AppTextStyles.font14SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.9, end: 1.0, duration: 300.ms);
  }
}

class _FailureState extends StatelessWidget {
  const _FailureState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(32)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: rw(48), color: AppColors.red200),
            verticalSpacing(12),
            Text(
              message.isNotEmpty ? message : 'import_failed'.tr(),
              style: AppTextStyles.font14SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue200,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rr(14)),
                ),
              ),
              child: Text('errors.error_screen_button'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
