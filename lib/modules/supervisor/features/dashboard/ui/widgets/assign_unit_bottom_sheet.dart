import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';
import 'package:ground_scope/core/widgets/ui/loaders/overlay_loader.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/models/service_request_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/logic/cubit/assign_unit_cubit.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/logic/cubit/dashboard_cubit.dart';

class AssignUnitBottomSheet extends StatelessWidget {
  const AssignUnitBottomSheet({super.key, required this.request});

  final ServiceRequestModel request;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocListener<AssignUnitCubit, AssignUnitState>(
      listener: (context, state) {
        if (state.status == AssignUnitStatus.success) {
          context.read<DashboardCubit>().onServiceRequestAssigned(request.id);
          Navigator.of(context).pop();
          context.showSuccessSnackBar('task_assigned'.tr());
        }
        if (state.status == AssignUnitStatus.failure) {
          context.showErrorSnackBar(state.error!.messageKey);
        }
      },
      child: BlocBuilder<AssignUnitCubit, AssignUnitState>(
        builder: (context, state) {
          final isAssigning = state.status == AssignUnitStatus.assigning;

          return OverlayLoader(
            isLoading: isAssigning,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: cc.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(rr(16)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: rh(12), bottom: rh(4)),
                      width: rw(40),
                      height: rh(4),
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(rr(2)),
                      ),
                    ),
                  ),
                  // Header row
                  Padding(
                    padding: EdgeInsets.fromLTRB(rw(16), rh(8), rw(8), rh(4)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'assign_unit_title'.tr(),
                                style: AppTextStyles.font18ExtraBold
                                    .copyWith(color: cc.textPrimary),
                              ),
                              verticalSpacing(2),
                              Text(
                                '${request.flight?.flightNumber ?? '-'} · ${request.flight?.stand?.code ?? '-'}',
                                style: AppTextStyles.font14Light
                                    .copyWith(color: cc.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: cc.iconSecondary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: cc.border),
                  // Search field
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        rw(16), rh(12), rw(16), rh(6)),
                    child: CustomTextForm(
                      hintText: 'search_units'.tr(),
                      prefixIcon: Icon(
                        Icons.search,
                        color: cc.iconSecondary,
                        size: rf(20),
                      ),
                      onChanged: context.read<AssignUnitCubit>().setSearch,
                    ),
                  ),
                  // Result counter
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: rw(16), vertical: rh(4)),
                    child: Text(
                      '${state.resultCount} ${'results'.tr()}',
                      style: AppTextStyles.font12SemiBold
                          .copyWith(color: cc.textSecondary),
                    ),
                  ),
                  // Unit list
                  Flexible(
                    child: _UnitList(
                      state: state,
                      isAssigning: isAssigning,
                      request: request,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UnitList extends StatelessWidget {
  const _UnitList({
    required this.state,
    required this.isAssigning,
    required this.request,
  });

  final AssignUnitState state;
  final bool isAssigning;
  final ServiceRequestModel request;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    if (state.status == AssignUnitStatus.loading ||
        state.status == AssignUnitStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary200),
      );
    }

    if (state.status == AssignUnitStatus.failure &&
        state.filteredUnits.isEmpty) {
      return _EmptyState(
        icon: Icons.cloud_off_outlined,
        message: state.error?.messageKey ?? 'errors.unknown'.tr(),
      );
    }

    if (state.filteredUnits.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_outlined,
        message: 'no_results_found'.tr(),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: state.filteredUnits.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: cc.border.withValues(alpha: 0.5)),
      itemBuilder: (context, index) {
        final unit = state.filteredUnits[index];
        return _UnitPickerRow(
          unit: unit,
          isAssigning: isAssigning,
          onAssign: () => context.read<AssignUnitCubit>().assign(
                requestId: request.id,
                unit: unit,
              ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: rf(48), color: cc.iconSecondary),
            verticalSpacing(12),
            Text(
              message,
              style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitPickerRow extends StatelessWidget {
  const _UnitPickerRow({
    required this.unit,
    required this.isAssigning,
    required this.onAssign,
  });

  final UnitModel unit;
  final bool isAssigning;
  final VoidCallback onAssign;

  String _shiftLabel() {
    final start = unit.shiftStartTime;
    final end = unit.shiftEndTime;
    if (start == null || end == null) return '-';
    String fmt(String t) => t.length >= 5 ? t.substring(0, 5) : t;
    return '${fmt(start)} – ${fmt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
      child: Row(
        children: [
          Container(
            width: rw(42),
            height: rw(42),
            decoration: BoxDecoration(
              color: AppColors.green200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(12)),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: AppColors.green200,
              size: rf(20),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: AppTextStyles.font14ExtraBold
                      .copyWith(color: cc.textPrimary),
                ),
                verticalSpacing(2),
                Text(
                  _shiftLabel(),
                  style:
                      AppTextStyles.font12Light.copyWith(color: cc.textHint),
                ),
              ],
            ),
          ),
          horizontalSpacing(8),
          CustomTextButton(
            text: 'assign'.tr(),
            onPressed: isAssigning ? null : onAssign,
            size: CustomButtonSize.small,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}