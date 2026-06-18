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

class AssignUnitBottomSheet extends StatefulWidget {
  const AssignUnitBottomSheet({super.key, required this.request});

  final ServiceRequestModel request;

  @override
  State<AssignUnitBottomSheet> createState() => _AssignUnitBottomSheetState();
}

class _AssignUnitBottomSheetState extends State<AssignUnitBottomSheet> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1 state
  DateTime? _scheduledStart;
  DateTime? _scheduledEnd;
  String _priority = 'medium';
  final _notesController = TextEditingController();
  final _checklistController = TextEditingController();
  final List<String> _checklistItems = [];

  // Step 2 state — selected unit
  UnitModel? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _scheduledStart = widget.request.flight?.scheduledArrival;
    _scheduledEnd   = widget.request.flight?.scheduledDeparture;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final base = isStart
        ? (_scheduledStart ?? DateTime.now())
        : (_scheduledEnd   ?? DateTime.now().add(const Duration(hours: 2)));
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base));
    if (picked == null) return;
    final now = DateTime.now();
    final dt  = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    setState(() => isStart ? _scheduledStart = dt : _scheduledEnd = dt);
  }

  void _addChecklistItem() {
    final text = _checklistController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checklistItems.add(text);
      _checklistController.clear();
    });
  }

  void _removeChecklistItem(int index) =>
      setState(() => _checklistItems.removeAt(index));

  bool _validateStep1() {
    if (_scheduledStart == null || _scheduledEnd == null) {
      context.showErrorSnackBar('please_set_valid_times'.tr());
      return false;
    }
    if (_scheduledEnd!.isBefore(_scheduledStart!)) {
      context.showErrorSnackBar('end_before_start'.tr());
      return false;
    }
    return true;
  }

  void _goToStep2() {
    if (!_validateStep1()) return;
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = 1);
  }

  void _goToStep1() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = 0);
  }

  void _onSelectUnit(UnitModel unit) {
    setState(() => _selectedUnit = unit);
    context.read<AssignUnitCubit>().createTask(
      request:        widget.request,
      unit:           unit,
      priority:       _priority,
      scheduledStart: _scheduledStart!,
      scheduledEnd:   _scheduledEnd!,
      checklistItems: List.unmodifiable(_checklistItems),
      notes:          _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocListener<AssignUnitCubit, AssignUnitState>(
      listener: (context, state) {
        if (state.status == AssignUnitStatus.success) {
          context.read<DashboardCubit>().onServiceRequestAssigned(widget.request.id);
          Navigator.of(context).pop();
          context.showSuccessSnackBar('task_created'.tr());
        }
        if (state.status == AssignUnitStatus.failure) {
          context.showErrorSnackBar(state.error!.messageKey);
          setState(() => _selectedUnit = null);
        }
      },
      child: BlocBuilder<AssignUnitCubit, AssignUnitState>(
        builder: (context, state) {
          final isAssigning = state.status == AssignUnitStatus.assigning;

          return OverlayLoader(
            isLoading: isAssigning,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: cc.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(rr(16))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(rw(16), rh(4), rw(8), rh(4)),
                    child: Row(
                      children: [
                        if (_currentPage == 1)
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new,
                                size: rf(18), color: cc.textPrimary),
                            onPressed: _goToStep1,
                          )
                        else
                          horizontalSpacing(8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'create_task'.tr(),
                                style: AppTextStyles.font18ExtraBold
                                    .copyWith(color: cc.textPrimary),
                              ),
                              verticalSpacing(2),
                              Text(
                                _currentPage == 0
                                    ? 'step_1_of_2'.tr()
                                    : 'step_2_of_2'.tr(),
                                style: AppTextStyles.font12Light
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
                  // Step indicator
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(4)),
                    child: _StepIndicator(currentPage: _currentPage),
                  ),
                  Divider(height: 1, color: cc.border),
                  // Pages
                  Flexible(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _Step1Form(
                          scheduledStart:    _scheduledStart,
                          scheduledEnd:      _scheduledEnd,
                          priority:          _priority,
                          notesController:   _notesController,
                          checklistController: _checklistController,
                          checklistItems:    _checklistItems,
                          onPickStart:       () => _pickTime(isStart: true),
                          onPickEnd:         () => _pickTime(isStart: false),
                          onPriorityChanged: (p) => setState(() => _priority = p),
                          onAddItem:         _addChecklistItem,
                          onRemoveItem:      _removeChecklistItem,
                          onNext:            _goToStep2,
                        ),
                        _Step2UnitPicker(
                          state:           state,
                          isAssigning:     isAssigning,
                          scheduledStart:  _scheduledStart,
                          scheduledEnd:    _scheduledEnd,
                          priority:        _priority,
                          checklistCount:  _checklistItems.length,
                          selectedUnit:    _selectedUnit,
                          onSelectUnit:    _onSelectUnit,
                        ),
                      ],
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

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentPage});
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dot(active: currentPage == 0),
        horizontalSpacing(6),
        _Dot(active: currentPage == 1),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width:  active ? rw(20) : rw(8),
      height: rh(6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary200 : AppColors.grey200,
        borderRadius: BorderRadius.circular(rr(4)),
      ),
    );
  }
}

// ─── Step 1: Schedule + Priority + Notes + Checklist ─────────────────────────

class _Step1Form extends StatelessWidget {
  const _Step1Form({
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.priority,
    required this.notesController,
    required this.checklistController,
    required this.checklistItems,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onPriorityChanged,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onNext,
  });

  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String priority;
  final TextEditingController notesController;
  final TextEditingController checklistController;
  final List<String> checklistItems;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), rh(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Schedule
                _SectionLabel(label: 'schedule'.tr()),
                verticalSpacing(8),
                Row(
                  children: [
                    Expanded(
                      child: _TimePickerButton(
                        label: 'start_time'.tr(),
                        time: scheduledStart,
                        onTap: onPickStart,
                      ),
                    ),
                    horizontalSpacing(8),
                    Expanded(
                      child: _TimePickerButton(
                        label: 'end_time'.tr(),
                        time: scheduledEnd,
                        onTap: onPickEnd,
                      ),
                    ),
                  ],
                ),
                verticalSpacing(20),
                // Priority
                _SectionLabel(label: 'priority'.tr()),
                verticalSpacing(8),
                _PrioritySelector(
                  selected: priority,
                  onChanged: onPriorityChanged,
                ),
                verticalSpacing(20),
                // Notes
                _SectionLabel(label: 'notes_optional'.tr()),
                verticalSpacing(8),
                CustomTextForm(
                  controller: notesController,
                  hintText: 'task_notes_hint'.tr(),
                  maxLines: 3,
                ),
                verticalSpacing(20),
                // Checklist
                _SectionLabel(label: 'checklist'.tr()),
                verticalSpacing(8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextForm(
                        controller: checklistController,
                        hintText: 'add_checklist_item'.tr(),
                      ),
                    ),
                    horizontalSpacing(8),
                    _AddButton(onTap: onAddItem),
                  ],
                ),
                if (checklistItems.isNotEmpty) ...[
                  verticalSpacing(8),
                  ...checklistItems.asMap().entries.map(
                        (e) => _ChecklistItemRow(
                          index: e.key,
                          text: e.value,
                          onRemove: onRemoveItem,
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(rw(16), rh(8), rw(16), rh(16)),
          child: CustomTextButton(
            text: 'next_select_unit'.tr(),
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

// ─── Step 2: Summary chips + unit picker ─────────────────────────────────────

class _Step2UnitPicker extends StatelessWidget {
  const _Step2UnitPicker({
    required this.state,
    required this.isAssigning,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.priority,
    required this.checklistCount,
    required this.selectedUnit,
    required this.onSelectUnit,
  });

  final AssignUnitState state;
  final bool isAssigning;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String priority;
  final int checklistCount;
  final UnitModel? selectedUnit;
  final void Function(UnitModel) onSelectUnit;

  String _fmt(BuildContext ctx, DateTime? dt) =>
      dt != null ? TimeOfDay.fromDateTime(dt).format(ctx) : '--:--';

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task summary chips
        Padding(
          padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), rh(4)),
          child: _TaskSummaryChips(
            startTime:      _fmt(context, scheduledStart),
            endTime:        _fmt(context, scheduledEnd),
            priority:       priority,
            checklistCount: checklistCount,
          ),
        ),
        // Search field
        Padding(
          padding: EdgeInsets.fromLTRB(rw(16), rh(8), rw(16), rh(6)),
          child: CustomTextForm(
            hintText: 'search_units'.tr(),
            prefixIcon: Icon(Icons.search, color: cc.iconSecondary, size: rf(20)),
            onChanged: context.read<AssignUnitCubit>().setSearch,
          ),
        ),
        // Result count
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(4)),
          child: Text(
            '${state.resultCount} ${'results'.tr()}',
            style: AppTextStyles.font12SemiBold.copyWith(color: cc.textSecondary),
          ),
        ),
        Divider(height: 1, color: cc.border),
        // Unit list
        Flexible(
          child: _UnitList(
            state:        state,
            isAssigning:  isAssigning,
            selectedUnit: selectedUnit,
            onSelect:     onSelectUnit,
          ),
        ),
      ],
    );
  }
}

class _TaskSummaryChips extends StatelessWidget {
  const _TaskSummaryChips({
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.checklistCount,
  });

  final String startTime;
  final String endTime;
  final String priority;
  final int checklistCount;

  Color _priorityColor() => switch (priority) {
        'low'      => AppColors.grey400,
        'medium'   => AppColors.amber200,
        'high'     => AppColors.red200,
        'critical' => const Color(0xFF7B1FA2),
        _          => AppColors.amber200,
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: rw(8),
      runSpacing: rh(6),
      children: [
        _SummaryChip(
          icon: Icons.access_time_outlined,
          label: '$startTime – $endTime',
          color: AppColors.primary200,
        ),
        _SummaryChip(
          icon: Icons.flag_outlined,
          label: priority,
          color: _priorityColor(),
        ),
        if (checklistCount > 0)
          _SummaryChip(
            icon: Icons.checklist_outlined,
            label: '$checklistCount ${'items'.tr()}',
            color: AppColors.green200,
          ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(5)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: rf(13), color: color),
          horizontalSpacing(4),
          Text(label,
              style: AppTextStyles.font12SemiBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── Unit list ───────────────────────────────────────────────────────────────

class _UnitList extends StatelessWidget {
  const _UnitList({
    required this.state,
    required this.isAssigning,
    required this.selectedUnit,
    required this.onSelect,
  });

  final AssignUnitState state;
  final bool isAssigning;
  final UnitModel? selectedUnit;
  final void Function(UnitModel) onSelect;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    if (state.status == AssignUnitStatus.loading ||
        state.status == AssignUnitStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary200),
      );
    }

    if (state.status == AssignUnitStatus.failure && state.filteredUnits.isEmpty) {
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
      itemBuilder: (_, index) {
        final unit = state.filteredUnits[index];
        return _UnitPickerRow(
          unit:        unit,
          isAssigning: isAssigning,
          isSelected:  selectedUnit?.id == unit.id,
          onSelect:    () => onSelect(unit),
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
    required this.isSelected,
    required this.onSelect,
  });

  final UnitModel unit;
  final bool isAssigning;
  final bool isSelected;
  final VoidCallback onSelect;

  String _shiftLabel() {
    final start = unit.shiftStartTime;
    final end   = unit.shiftEndTime;
    if (start == null || end == null) return '-';
    String fmt(String t) => t.length >= 5 ? t.substring(0, 5) : t;
    return '${fmt(start)} – ${fmt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
      child: Row(
        children: [
          Container(
            width:  rw(42),
            height: rw(42),
            decoration: BoxDecoration(
              color:  AppColors.green200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(12)),
            ),
            child: Icon(Icons.local_shipping_outlined,
                color: AppColors.green200, size: rf(20)),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit.name,
                    style: AppTextStyles.font14ExtraBold
                        .copyWith(color: cc.textPrimary)),
                verticalSpacing(2),
                Text(_shiftLabel(),
                    style: AppTextStyles.font12Light
                        .copyWith(color: cc.textHint)),
              ],
            ),
          ),
          horizontalSpacing(8),
          CustomTextButton(
            text: 'assign'.tr(),
            onPressed: (isAssigning || isSelected) ? null : onSelect,
            size: CustomButtonSize.small,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.font12SemiBold.copyWith(
        color: context.customColors.textSecondary,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final DateTime? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final displayTime =
        time != null ? TimeOfDay.fromDateTime(time!).format(context) : '--:--';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(10)),
        decoration: BoxDecoration(
          color: cc.surfaceVariant,
          borderRadius: BorderRadius.circular(rr(10)),
          border: Border.all(color: cc.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.font12Light.copyWith(color: cc.textHint)),
            verticalSpacing(2),
            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    size: rf(14), color: cc.iconSecondary),
                horizontalSpacing(4),
                Text(displayTime,
                    style: AppTextStyles.font14SemiBold
                        .copyWith(color: cc.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  static const _priorities = ['low', 'medium', 'high', 'critical'];

  Color _color(String p) => switch (p) {
        'low'      => AppColors.grey400,
        'medium'   => AppColors.amber200,
        'high'     => AppColors.red200,
        'critical' => const Color(0xFF7B1FA2),
        _          => AppColors.amber200,
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: rw(8),
      runSpacing: rh(8),
      children: _priorities.map((p) {
        final isSelected = p == selected;
        final color = _color(p);
        return GestureDetector(
          onTap: () => onChanged(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(8)),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(rr(20)),
              border: Border.all(
                color: isSelected ? color : context.customColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              p,
              style: AppTextStyles.font12SemiBold.copyWith(
                color: isSelected ? color : context.customColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  rw(44),
        height: rw(44),
        decoration: BoxDecoration(
          color: AppColors.primary200,
          borderRadius: BorderRadius.circular(rr(10)),
        ),
        child: Icon(Icons.add, color: Colors.white, size: rf(22)),
      ),
    );
  }
}

class _ChecklistItemRow extends StatelessWidget {
  const _ChecklistItemRow({
    required this.index,
    required this.text,
    required this.onRemove,
  });

  final int index;
  final String text;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.only(bottom: rh(6)),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: rf(16), color: AppColors.primary200),
          horizontalSpacing(8),
          Expanded(
            child: Text(text,
                style: AppTextStyles.font12Light.copyWith(color: cc.textPrimary)),
          ),
          GestureDetector(
            onTap: () => onRemove(index),
            child: Icon(Icons.close, size: rf(16), color: cc.iconSecondary),
          ),
        ],
      ),
    );
  }
}
