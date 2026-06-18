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
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_status_badge.dart';
import 'package:ground_scope/modules/admin/features/service_requests/logic/cubit/service_request_cubit.dart';
import 'widgets/service_request_empty_state.dart';
import 'widgets/service_request_tile.dart';
import 'widgets/service_type_selector.dart';

class FlightServiceRequestScreen extends StatelessWidget {
  const FlightServiceRequestScreen({super.key, required this.flight});

  final FlightModel flight;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      body: SafeArea(
        child: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
          listenWhen: (prev, curr) =>
              curr.status == SrLoadStatus.success && prev.status == SrLoadStatus.submitting ||
              curr.status == SrLoadStatus.failure && prev.error != curr.error,
          listener: (context, state) {
            if (state.status == SrLoadStatus.success &&
                state.existingRequests.isNotEmpty) {
              final count = state.existingRequests
                  .where((r) => r.isPending)
                  .length;
              if (count > 0) {
                context.showSuccessSnackBar(
                  'requests_sent'.tr(namedArgs: {'count': '$count'}),
                );
              }
            }
            if (state.status == SrLoadStatus.failure && state.error != null) {
              context.showErrorSnackBar(state.error!.messageKey);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _AppBar(flight: flight),
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ServiceRequestState state) {
    if (state.status == SrLoadStatus.loading ||
        state.status == SrLoadStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary200),
      );
    }

    if (state.status == SrLoadStatus.failure &&
        state.existingRequests.isEmpty) {
      return _ErrorState(
        message: state.error?.messageKey ?? 'errors.unknown'.tr(),
        onRetry: () => context.read<ServiceRequestCubit>().init(flight),
      );
    }

    return _Content(flight: flight);
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.flight});

  final FlightModel flight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(8)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: context.pop,
            color: context.customColors.textPrimary,
          ),
          Expanded(
            child: Text(
              'request_services'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.font18SemiBold
                  .copyWith(color: context.customColors.textPrimary),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.flight});

  final FlightModel flight;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
      builder: (context, state) {
        final isSubmitting = state.status == SrLoadStatus.submitting;
        final selectedCount = state.selectedServiceTypeIds.length;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(rw(20), rh(8), rw(20), rh(100)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flight info card
                  _FlightInfoCard(flight: state.flight ?? flight)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms),
                  verticalSpacing(24),
                  // Existing requests section
                  _SectionHeader(title: 'existing_requests'.tr())
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 300.ms),
                  verticalSpacing(10),
                  if (state.existingRequests.isEmpty)
                    const ServiceRequestEmptyState()
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 300.ms)
                  else
                    ...state.existingRequests.map((req) => ServiceRequestTile(
                          request: req,
                          onCancel: () => _confirmCancel(context, req.id),
                        ).animate(delay: 100.ms).fadeIn(duration: 300.ms)),
                  verticalSpacing(24),
                  // New services section
                  _SectionHeader(title: 'request_new_services'.tr())
                      .animate(delay: 160.ms)
                      .fadeIn(duration: 300.ms),
                  verticalSpacing(6),
                  Text(
                    'select_services_hint'.tr(),
                    style: AppTextStyles.font12Light
                        .copyWith(color: cc.textSecondary),
                  ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
                  verticalSpacing(10),
                  ServiceTypeSelector(
                    serviceTypes: state.availableServiceTypes,
                    selectedIds:  state.selectedServiceTypeIds,
                    onToggle:     context.read<ServiceRequestCubit>().toggleServiceType,
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
                  verticalSpacing(16),
                  // Notes field
                  CustomTextForm(
                    hintText: 'service_request_notes'.tr(),
                    maxLines: 3,
                    onChanged:
                        context.read<ServiceRequestCubit>().onNotesChanged,
                  ).animate(delay: 240.ms).fadeIn(duration: 300.ms),
                ],
              ),
            ),
            // Submit button pinned at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    rw(20), rh(12), rw(20), rh(16)),
                decoration: BoxDecoration(
                  color: cc.background,
                  border: Border(top: BorderSide(color: cc.border)),
                ),
                child: CustomTextButton(
                  text: isSubmitting
                      ? '...'
                      : 'send_requests'.tr(
                          namedArgs: {'count': '$selectedCount'}),
                  onPressed: selectedCount == 0 || isSubmitting
                      ? null
                      : () => context
                          .read<ServiceRequestCubit>()
                          .submitRequests(),
                  isLoading: isSubmitting,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context, String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('cancel_request'.tr()),
        content: Text('confirm_cancel_request'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              'cancel_request'.tr(),
              style: const TextStyle(color: AppColors.red200),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ServiceRequestCubit>().cancelRequest(requestId);
      if (context.mounted) {
        context.showSuccessSnackBar('request_cancelled'.tr());
      }
    }
  }
}

class _FlightInfoCard extends StatelessWidget {
  const _FlightInfoCard({required this.flight});

  final FlightModel flight;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: cc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flight_outlined,
                  size: rf(20), color: AppColors.primary200),
              horizontalSpacing(8),
              Expanded(
                child: Text(
                  '${flight.flightNumber}  ·  ${flight.airline}',
                  style: AppTextStyles.font16SemiBold
                      .copyWith(color: cc.textPrimary),
                ),
              ),
              FlightStatusBadge(status: flight.status),
            ],
          ),
          verticalSpacing(8),
          Text(
            '${flight.origin} → ${flight.destination}',
            style: AppTextStyles.font14Light.copyWith(color: cc.textSecondary),
          ),
          verticalSpacing(8),
          Row(
            children: [
              Icon(Icons.access_time_outlined,
                  size: rf(14), color: cc.iconSecondary),
              horizontalSpacing(4),
              Text(
                flight.scheduledArrival.formattedTime,
                style:
                    AppTextStyles.font12Light.copyWith(color: cc.textSecondary),
              ),
              if (flight.stand != null) ...[
                horizontalSpacing(12),
                Icon(Icons.local_parking_outlined,
                    size: rf(14), color: cc.iconSecondary),
                horizontalSpacing(4),
                Text(
                  flight.stand!.code,
                  style: AppTextStyles.font12Light
                      .copyWith(color: cc.textSecondary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.font12SemiBold.copyWith(
        color: context.customColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: rf(48), color: context.customColors.iconSecondary),
            verticalSpacing(12),
            Text(
              message,
              style: AppTextStyles.font14Light
                  .copyWith(color: context.customColors.textHint),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(16),
            CustomTextButton(text: 'retry'.tr(), onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
