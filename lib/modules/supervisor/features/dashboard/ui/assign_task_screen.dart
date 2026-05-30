import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/utils/task_ui_helpers.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/widgets/custom_app_bar.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/logic/cubit/assign_task_cubit.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerFade() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Scaffold(
      backgroundColor: cc.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            CustomAppBar(title: 'supervisor_dashboard.assign_task_title'.tr()),
            Expanded(
              child: BlocConsumer<AssignTaskCubit, AssignTaskState>(
                listener: (context, state) {
                  if (state.status == AssignTaskStatus.success) {
                    context.read<SupervisorDashboardCubit>().refresh();
                    context.showSuccessSnackBar(
                      'supervisor_dashboard.task_assigned_success'.tr(),
                    );
                    if (Navigator.canPop(context)) context.pop();
                  } else if (state.status == AssignTaskStatus.failure &&
                      state.error != null) {
                    context.showErrorSnackBar(state.error!.messageKey);
                  }
                },
                builder: (context, state) {
                  if (state.status == AssignTaskStatus.loadingFormData ||
                      state.status == AssignTaskStatus.initial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary200,
                      ),
                    );
                  }
                  if (state.status == AssignTaskStatus.failure) {
                    return _ErrorBody(
                      onRetry: () =>
                          context.read<AssignTaskCubit>().loadFormData(),
                    );
                  }
                  _triggerFade();
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                          rw(20), rh(8), rw(20), rh(40)),
                      child: _FormBody(state: state),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Input Decoration ----------

InputDecoration _inputDecoration(BuildContext context) {
  final cc = context.customColors;
  return InputDecoration(
    filled: true,
    fillColor: cc.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
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
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(12)),
      borderSide: BorderSide(color: cc.border.withValues(alpha: 0.25)),
    ),
  );
}

// ---------- Error State ----------

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: rf(48), color: cc.textDisabled),
          verticalSpacing(12),
          Text(
            'supervisor_dashboard.load_form_failed'.tr(),
            style: AppTextStyles.font14Light.copyWith(color: cc.textSecondary),
            textAlign: TextAlign.center,
          ),
          verticalSpacing(8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('supervisor_dashboard.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

// ---------- Form Body ----------

class _FormBody extends StatelessWidget {
  const _FormBody({required this.state});

  final AssignTaskState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssignTaskCubit>();
    final cc = context.customColors;
    final isSubmitting = state.status == AssignTaskStatus.submitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Flight ───────────────────────────────────────────────────────────
        _SectionLabel('supervisor_dashboard.select_flight'.tr()),
        verticalSpacing(8),
        DropdownButtonFormField<String>(
          initialValue: state.selectedFlight?.id,
          hint: Text(
            'supervisor_dashboard.select_flight'.tr(),
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: cc.textHint,
            size: rf(20),
          ),
          items: state.flights.isEmpty
              ? [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'supervisor_dashboard.no_upcoming_flights'.tr(),
                      style:
                          AppTextStyles.font14Light.copyWith(color: cc.textHint),
                    ),
                  ),
                ]
              : state.flights
                  .map(
                    (f) => DropdownMenuItem(
                      value: f.id,
                      child: Text(
                        '${f.flightNumber} — ${f.origin} → ${f.destination}',
                        style: AppTextStyles.font14Light
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
          style: AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
        ),

        verticalSpacing(20),

        // ── Service Type ─────────────────────────────────────────────────────
        _SectionLabel('supervisor_dashboard.select_service_type'.tr()),
        verticalSpacing(8),
        DropdownButtonFormField<String>(
          initialValue: state.selectedServiceType?.id,
          hint: Text(
            'supervisor_dashboard.select_service_type'.tr(),
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: cc.textHint,
            size: rf(20),
          ),
          items: state.serviceTypes
              .map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(
                    s.name,
                    style:
                        AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
                  ),
                ),
              )
              .toList(),
          onChanged: (id) {
            if (id != null) cubit.selectServiceType(id);
          },
          decoration: _inputDecoration(context),
          dropdownColor: cc.surface,
          style: AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
        ),

        verticalSpacing(20),

        // ── Unit ─────────────────────────────────────────────────────────────
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
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: cc.textHint,
            size: rf(20),
          ),
          items: state.filteredUnits
              .map(
                (u) => DropdownMenuItem(
                  value: u.id,
                  child: Text(
                    u.name,
                    style:
                        AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
                  ),
                ),
              )
              .toList(),
          onChanged:
              state.selectedServiceType == null || state.filteredUnits.isEmpty
                  ? null
                  : (id) {
                      if (id != null) cubit.selectUnit(id);
                    },
          decoration: _inputDecoration(context),
          dropdownColor: cc.surface,
          style: AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
        ),

        verticalSpacing(20),

        // ── Priority ─────────────────────────────────────────────────────────
        _SectionLabel('supervisor_dashboard.priority'.tr()),
        verticalSpacing(8),
        _PriorityChipRow(
          selected: state.priority,
          onSelected: cubit.setPriority,
        ),

        verticalSpacing(20),

        // ── Start Time ───────────────────────────────────────────────────────
        _SectionLabel('supervisor_dashboard.start_time'.tr()),
        verticalSpacing(8),
        _TimePicker(
          value: state.scheduledStart,
          hint: 'supervisor_dashboard.start_time'.tr(),
          onPicked: cubit.setScheduledStart,
        ),

        verticalSpacing(20),

        // ── End Time ─────────────────────────────────────────────────────────
        _SectionLabel('supervisor_dashboard.end_time'.tr()),
        verticalSpacing(8),
        _TimePicker(
          value: state.scheduledEnd,
          hint: 'supervisor_dashboard.end_time'.tr(),
          onPicked: cubit.setScheduledEnd,
          errorText: state.scheduledEnd != null &&
                  state.scheduledStart != null &&
                  !state.scheduledEnd!.isAfter(state.scheduledStart!)
              ? 'supervisor_dashboard.end_after_start_error'.tr()
              : null,
        ),

        verticalSpacing(20),

        // ── Notes ────────────────────────────────────────────────────────────
        _SectionLabel('supervisor_dashboard.notes_optional'.tr()),
        verticalSpacing(8),
        CustomTextForm(
          hintText: 'supervisor_dashboard.notes_optional'.tr(),
          maxLines: 4,
          maxLength: 500,
          onChanged: cubit.setNotes,
        ),

        verticalSpacing(28),

        // ── Actions ──────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: CustomTextButton.outlined(
                text: 'supervisor_dashboard.reset'.tr(),
                onPressed: isSubmitting ? null : cubit.reset,
                borderColor: cc.border,
                foregroundColor: cc.textSecondary,
              ),
            ),
            horizontalSpacing(12),
            Expanded(
              flex: 2,
              child: CustomTextButton(
                text: 'supervisor_dashboard.submit'.tr(),
                onPressed:
                    isSubmitting || !state.isFormValid ? null : cubit.submit,
                isLoading: isSubmitting,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------- Section Label ----------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.font12SemiBold.copyWith(
        color: context.customColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ---------- Priority Chip Row ----------

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
        final color = TaskUiHelpers.priorityColor(p);
        final isLast = p == TaskPriority.values.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : rw(6)),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(p);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: rh(10)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.12)
                      : context.customColors.surface,
                  borderRadius: BorderRadius.circular(rr(12)),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : context.customColors.border.withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _priorityIcon(p),
                      size: rf(16),
                      color: isSelected
                          ? color
                          : context.customColors.textHint,
                    ),
                    verticalSpacing(4),
                    Text(
                      p.label,
                      style: AppTextStyles.font12SemiBold.copyWith(
                        color: isSelected ? color : context.customColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _priorityIcon(TaskPriority p) => switch (p) {
        TaskPriority.low => Icons.keyboard_arrow_down_rounded,
        TaskPriority.medium => Icons.remove_rounded,
        TaskPriority.high => Icons.keyboard_arrow_up_rounded,
        TaskPriority.critical => Icons.priority_high_rounded,
      };
}

// ---------- Time Picker ----------

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
            HapticFeedback.selectionClick();
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
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
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
                  color: formatted != null ? AppColors.primary200 : cc.textHint,
                  size: rf(18),
                ),
                horizontalSpacing(10),
                Expanded(
                  child: Text(
                    formatted ?? hint,
                    style: AppTextStyles.font14Light.copyWith(
                      color: formatted != null ? cc.textPrimary : cc.textHint,
                    ),
                  ),
                ),
                if (formatted != null)
                  Icon(
                    Icons.edit_outlined,
                    color: cc.textHint,
                    size: rf(14),
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
