import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart';
import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../../core/utils/spacing.dart';
import '../../logic/cubit/assign_task_cubit.dart';

class AssignTaskBottomSheet extends StatelessWidget {
  const AssignTaskBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssignTaskCubit, AssignTaskState>(
      listener: (context, state) {
        if (state.status == AssignTaskStatus.success) {
          context.pop();
          context.read<SupervisorDashboardCubit>().refresh();
          context.showSuccessSnackBar(
            'supervisor_dashboard.task_assigned_success'.tr(),
          );
        } else if (state.status == AssignTaskStatus.failure &&
            state.error != null) {
          context.showErrorSnackBar(state.error!.messageKey);
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: context.customColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(rr(24)),
                ),
              ),
              child: Column(
                children: [
                  _DragHandle(),
                  _SheetHeader(),
                  Expanded(
                    child: state.status == AssignTaskStatus.loadingFormData
                        ? _LoadingSkeleton()
                        : state.status == AssignTaskStatus.failure &&
                                state.flights.isEmpty
                            ? _FormLoadError(
                                onRetry: () => context
                                    .read<AssignTaskCubit>()
                                    .loadFormData(),
                              )
                            : _SheetForm(scrollController: scrollController),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(12)),
      child: Container(
        width: rw(40),
        height: rh(4),
        decoration: BoxDecoration(
          color: cc.border,
          borderRadius: BorderRadius.circular(rr(2)),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.fromLTRB(rw(20), 0, rw(20), rh(12)),
      child: Row(
        children: [
          Text(
            'supervisor_dashboard.assign_task_title'.tr(),
            style: AppTextStyles.font18SemiBold.copyWith(color: cc.textPrimary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(Icons.close_rounded, color: cc.textHint, size: rf(22)),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.all(rw(20)),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: rh(16)),
            child: Container(
              height: rh(56),
              decoration: BoxDecoration(
                color: cc.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(rr(12)),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(
                  duration: 1200.ms,
                  color: cc.border.withValues(alpha: 0.6),
                ),
          ),
        ),
      ),
    );
  }
}

class _FormLoadError extends StatelessWidget {
  const _FormLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: rf(48), color: cc.textHint),
          verticalSpacing(12),
          Text(
            'supervisor_dashboard.load_form_failed'.tr(),
            style:
                AppTextStyles.font14SemiBold.copyWith(color: cc.textSecondary),
            textAlign: TextAlign.center,
          ),
          verticalSpacing(16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary200),
            child: Text('supervisor_dashboard.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _SheetForm extends StatelessWidget {
  const _SheetForm({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignTaskCubit, AssignTaskState>(
      builder: (context, state) {
        final cubit = context.read<AssignTaskCubit>();
        final cc = context.customColors;
        final isSubmitting = state.status == AssignTaskStatus.submitting;

        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(rw(20), rh(4), rw(20), rh(32)),
          children: [
            // Flight Dropdown
            _SectionLabel('supervisor_dashboard.select_flight'.tr()),
            verticalSpacing(8),
            DropdownButtonFormField<String>(
              initialValue: state.selectedFlight?.id,
              hint: Text(
                'supervisor_dashboard.select_flight'.tr(),
                style: AppTextStyles.font14SemiBold.copyWith(
                    color: cc.textHint),
              ),
              items: state.flights.isEmpty
                  ? [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          'supervisor_dashboard.no_upcoming_flights'.tr(),
                          style: AppTextStyles.font14SemiBold.copyWith(
                              color: cc.textHint),
                        ),
                      ),
                    ]
                  : state.flights
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(
                            '${f.flightNumber} — ${f.origin} → ${f.destination}',
                            style: AppTextStyles.font14SemiBold
                                .copyWith(color: cc.textPrimary),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: state.flights.isEmpty
                  ? null
                  : (id) {
                      if (id != null) cubit.selectFlight(id);
                    },
              decoration: _inputDecoration(context),
              dropdownColor: cc.surface,
            ),

            verticalSpacing(16),

            // Service Type Dropdown
            _SectionLabel('supervisor_dashboard.select_service_type'.tr()),
            verticalSpacing(8),
            DropdownButtonFormField<String>(
              initialValue: state.selectedServiceType?.id,
              hint: Text(
                'supervisor_dashboard.select_service_type'.tr(),
                style: AppTextStyles.font14SemiBold.copyWith(
                    color: cc.textHint),
              ),
              items: state.serviceTypes
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        s.name,
                        style: AppTextStyles.font14SemiBold
                            .copyWith(color: cc.textPrimary),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id != null) cubit.selectServiceType(id);
              },
              decoration: _inputDecoration(context),
              dropdownColor: cc.surface,
            ),

            verticalSpacing(16),

            // Unit Dropdown
            _SectionLabel('supervisor_dashboard.select_unit'.tr()),
            verticalSpacing(8),
            DropdownButtonFormField<String>(
              initialValue: state.selectedUnit?.id,
              hint: Text(
                state.selectedServiceType == null
                    ? 'supervisor_dashboard.select_service_type'.tr()
                    : state.filteredUnits.isEmpty
                        ? 'supervisor_dashboard.no_units_for_service'.tr()
                        : 'supervisor_dashboard.select_unit'.tr(),
                style: AppTextStyles.font14SemiBold.copyWith(
                    color: cc.textHint),
              ),
              items: state.filteredUnits
                  .map(
                    (u) => DropdownMenuItem(
                      value: u.id,
                      child: Text(
                        u.name,
                        style: AppTextStyles.font14SemiBold
                            .copyWith(color: cc.textPrimary),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: state.selectedServiceType == null ||
                      state.filteredUnits.isEmpty
                  ? null
                  : (id) {
                      if (id != null) cubit.selectUnit(id);
                    },
              decoration: _inputDecoration(context),
              dropdownColor: cc.surface,
            ),

            verticalSpacing(16),

            // Priority Chips
            _SectionLabel('supervisor_dashboard.priority'.tr()),
            verticalSpacing(8),
            _PriorityChipRow(
              selected: state.priority,
              onSelected: cubit.setPriority,
            ),

            verticalSpacing(16),

            // Start Time
            _SectionLabel('supervisor_dashboard.start_time'.tr()),
            verticalSpacing(8),
            _TimePicker(
              value: state.scheduledStart,
              hint: 'supervisor_dashboard.start_time'.tr(),
              onPicked: (dt) {
                cubit.setScheduledStart(dt);
              },
            ),

            verticalSpacing(16),

            // End Time
            _SectionLabel('supervisor_dashboard.end_time'.tr()),
            verticalSpacing(8),
            _TimePicker(
              value: state.scheduledEnd,
              hint: 'supervisor_dashboard.end_time'.tr(),
              onPicked: (dt) {
                cubit.setScheduledEnd(dt);
              },
              errorText:
                  state.scheduledEnd != null &&
                          state.scheduledStart != null &&
                          !state.scheduledEnd!.isAfter(state.scheduledStart!)
                      ? 'supervisor_dashboard.end_after_start_error'.tr()
                      : null,
            ),

            verticalSpacing(16),

            // Notes
            _SectionLabel('supervisor_dashboard.notes_optional'.tr()),
            verticalSpacing(8),
            TextFormField(
              maxLength: 500,
              maxLines: 3,
              onChanged: cubit.setNotes,
              style: AppTextStyles.font14SemiBold.copyWith(color: cc.textPrimary),
              decoration: _inputDecoration(context).copyWith(
                hintText: 'supervisor_dashboard.notes_optional'.tr(),
                counterStyle:
                    AppTextStyles.font12Light.copyWith(color: cc.textHint),
              ),
            ),

            verticalSpacing(24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : cubit.reset,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: rh(14)),
                      side: BorderSide(color: cc.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rr(12)),
                      ),
                    ),
                    child: Text(
                      'supervisor_dashboard.reset'.tr(),
                      style: AppTextStyles.font16SemiBold.copyWith(
                        color: cc.textSecondary,
                      ),
                    ),
                  ),
                ),
                horizontalSpacing(12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: isSubmitting || !state.isFormValid
                        ? null
                        : cubit.submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary200,
                      disabledBackgroundColor:
                          AppColors.primary200.withValues(alpha: 0.4),
                      padding: EdgeInsets.symmetric(vertical: rh(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rr(12)),
                      ),
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            width: rw(20),
                            height: rw(20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'supervisor_dashboard.submit'.tr(),
                            style: AppTextStyles.font16SemiBold.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final cc = context.customColors;
    return InputDecoration(
      filled: true,
      fillColor: cc.surface,
      contentPadding:
          EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rr(12)),
        borderSide: BorderSide(color: cc.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rr(12)),
        borderSide: BorderSide(color: cc.border.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rr(12)),
        borderSide: const BorderSide(color: AppColors.primary200),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.font14SemiBold.copyWith(
        color: context.customColors.textSecondary,
      ),
    );
  }
}

class _PriorityChipRow extends StatelessWidget {
  const _PriorityChipRow({
    required this.selected,
    required this.onSelected,
  });

  final TaskPriority selected;
  final ValueChanged<TaskPriority> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((p) {
        final isSelected = p == selected;
        final color = _priorityColor(p);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: p != TaskPriority.critical ? rw(6) : 0),
            child: GestureDetector(
              onTap: () => onSelected(p),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: rh(10)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : context.customColors.surface,
                  borderRadius: BorderRadius.circular(rr(10)),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : context.customColors.border.withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    p.label,
                    style: AppTextStyles.font12SemiBold.copyWith(
                      color: isSelected ? color : context.customColors.textHint,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _priorityColor(TaskPriority p) => switch (p) {
    TaskPriority.low => AppColors.green200,
    TaskPriority.medium => AppColors.primary200,
    TaskPriority.high => AppColors.amber200,
    TaskPriority.critical => AppColors.red200,
  };
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.value,
    required this.hint,
    required this.onPicked,
    this.errorText,
  });

  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime> onPicked;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final formatted = value != null
        ? '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: value != null
                  ? TimeOfDay(hour: value!.hour, minute: value!.minute)
                  : TimeOfDay.now(),
            );
            if (picked != null) {
              final now = DateTime.now();
              onPicked(DateTime(
                now.year,
                now.month,
                now.day,
                picked.hour,
                picked.minute,
              ));
            }
          },
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
            decoration: BoxDecoration(
              color: cc.surface,
              borderRadius: BorderRadius.circular(rr(12)),
              border: Border.all(
                color: errorText != null
                    ? AppColors.red200
                    : cc.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: cc.textHint,
                  size: rf(18),
                ),
                horizontalSpacing(10),
                Text(
                  formatted ?? hint,
                  style: AppTextStyles.font14SemiBold.copyWith(
                    color: formatted != null ? cc.textPrimary : cc.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          verticalSpacing(4),
          Text(
            errorText!,
            style: AppTextStyles.font12Light.copyWith(color: AppColors.red200),
          ),
        ],
      ],
    );
  }
}
