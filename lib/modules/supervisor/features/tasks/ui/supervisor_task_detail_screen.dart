import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/utils/task_ui_helpers.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';
import '../logic/cubit/supervisor_task_detail_cubit.dart';

class SupervisorTaskDetailScreen extends StatefulWidget {
  const SupervisorTaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  State<SupervisorTaskDetailScreen> createState() =>
      _SupervisorTaskDetailScreenState();
}

class _SupervisorTaskDetailScreenState
    extends State<SupervisorTaskDetailScreen> {
  int _selectedSection = 0;

  @override
  void initState() {
    super.initState();
    context.read<SupervisorTaskDetailCubit>().loadTask(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupervisorTaskDetailCubit, SupervisorTaskDetailState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SupervisorTaskDetailStatus.updated) {
          context.showSuccessSnackBar('task_status_updated'.tr());
        } else if (state.status == SupervisorTaskDetailStatus.failure &&
            state.task != null) {
          context.showErrorSnackBar(
            state.error?.messageKey.tr() ?? 'something_went_wrong'.tr(),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.customColors.background,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SupervisorTaskDetailState state) {
    if (state.status == SupervisorTaskDetailStatus.loading ||
        state.status == SupervisorTaskDetailStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary200),
      );
    }

    if (state.status == SupervisorTaskDetailStatus.failure &&
        state.task == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: rf(48), color: AppColors.red200),
            verticalSpacing(12),
            Text(
              state.error?.messageKey.tr() ?? 'something_went_wrong'.tr(),
              style: AppTextStyles.font14Light
                  .copyWith(color: context.customColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(16),
            TextButton(
              onPressed: () => context
                  .read<SupervisorTaskDetailCubit>()
                  .loadTask(widget.taskId),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    final task = state.task;
    if (task == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: rh(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GradientHeader(task: task),
          verticalSpacing(16),
          _SectionToggle(
            selected: _selectedSection,
            onChanged: (i) => setState(() => _selectedSection = i),
          ),
          verticalSpacing(16),
          if (_selectedSection == 0)
            _TaskInfoSection(task: task, checklist: state.checklistItems)
          else
            _UnitCrewSection(
              task: task,
              isUpdating:
                  state.status == SupervisorTaskDetailStatus.updating,
              onUpdateStatus: (newStatus) => _confirmStatusChange(
                context,
                task,
                newStatus,
              ),
            ),
        ],
      ),
    );
  }

  void _confirmStatusChange(
      BuildContext context, TaskModel task, String newStatus) {
    AppDialogs.showConfirm(
      context,
      message: 'confirm_status_change'.tr(),
      onConfirm: () => context
          .read<SupervisorTaskDetailCubit>()
          .updateTaskStatus(task.id, newStatus),
    );
  }
}

// ─── Gradient Header ─────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary400,
            AppColors.primary300,
            AppColors.primary200,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: rw(20),
        right: rw(20),
        top: rh(46),
        bottom: rh(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: back button + title + priority badge ──────────────
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: rw(32),
                  height: rw(32),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
              horizontalSpacing(12),
              Expanded(
                child: Text(
                  'task_details'.tr(),
                  style: AppTextStyles.font16ExtraBold.copyWith(
                    color: AppColors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              _PriorityBadge(priority: task.priority),
            ],
          ),
          verticalSpacing(20),
          // ── Row 2: service icon + flight number + status badge ────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: rw(52),
                height: rw(52),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(rr(14)),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  _serviceTypeIcon(task.serviceTypeIcon),
                  color: AppColors.white,
                  size: rf(26),
                ),
              ),
              horizontalSpacing(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.flight?.flightNumber ??
                          task.serviceTypeName ??
                          'task'.tr(),
                      style: AppTextStyles.font22ExtraBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    verticalSpacing(4),
                    _StatusBadge(
                      status: task.status ?? TaskStatus.pending,
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(20),
          // ── Divider ────────────────────────────────────────────────────
          Container(
            height: 1,
            color: AppColors.white.withValues(alpha: 0.15),
          ),
          verticalSpacing(16),
          // ── Info pills row ─────────────────────────────────────────────
          Row(
            children: [
              if (task.serviceTypeName != null)
                _InfoPill(
                  icon: Icons.miscellaneous_services_rounded,
                  label: task.serviceTypeName!,
                ),
              if (task.serviceTypeName != null && task.flight?.stand?.code != null)
                horizontalSpacing(10),
              if (task.flight?.stand?.code != null)
                _InfoPill(
                  icon: Icons.location_on_rounded,
                  label: 'Stand ${task.flight!.stand!.code}',
                ),
              const Spacer(),
              _InfoPill(
                icon: Icons.timer_outlined,
                label: '${task.durationMinutes} ${'min'.tr()}',
              ),
            ],
          ),
          verticalSpacing(16),
          // ── Time window container ──────────────────────────────────────
          Container(
            padding: EdgeInsets.all(rw(14)),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(14)),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TimeColumn(
                    label: 'scheduled_start'.tr(),
                    time: task.scheduledStart.formattedTime,
                    subLabel: _dateLabel(task.scheduledStart),
                  ),
                ),
                Container(
                  width: 1,
                  height: rh(40),
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _TimeColumn(
                    label: 'scheduled_end'.tr(),
                    time: task.scheduledEnd.formattedTime,
                    subLabel: _dateLabel(task.scheduledEnd),
                  ),
                ),
                if (task.actualStart != null) ...[
                  Container(
                    width: 1,
                    height: rh(40),
                    color: AppColors.white.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _TimeColumn(
                      label: 'actual_start'.tr(),
                      time: task.actualStart!.formattedTime,
                      subLabel: _dateLabel(task.actualStart!),
                      highlight: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  IconData _serviceTypeIcon(String? icon) {
    return switch (icon) {
      'cleaning' => Icons.cleaning_services_rounded,
      'catering' => Icons.restaurant_rounded,
      'baggage' || 'luggage' => Icons.luggage_rounded,
      'fuel' || 'fueling' => Icons.local_gas_station_rounded,
      'maintenance' => Icons.build_rounded,
      'pushback' => Icons.airport_shuttle_rounded,
      'boarding' => Icons.airline_seat_recline_normal_rounded,
      _ => Icons.miscellaneous_services_rounded,
    };
  }
}

// ─── Section Toggle ───────────────────────────────────────────────────────────

class _SectionToggle extends StatelessWidget {
  const _SectionToggle({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16)),
      child: Row(
        children: [
          Expanded(
            child: _SectionCard(
              label: 'task_info'.tr(),
              icon: Icons.info_outline,
              isSelected: selected == 0,
              onTap: () => onChanged(0),
            ),
          ),
          horizontalSpacing(10),
          Expanded(
            child: _SectionCard(
              label: 'unit_and_crew'.tr(),
              icon: Icons.group_outlined,
              isSelected: selected == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Task Info Section ────────────────────────────────────────────────────────

class _TaskInfoSection extends StatelessWidget {
  const _TaskInfoSection({required this.task, required this.checklist});

  final TaskModel task;
  final List<TaskCheckListModel> checklist;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final flight = task.flight;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'flight_info'.tr()),
          verticalSpacing(10),
          Container(
            padding: EdgeInsets.all(rw(16)),
            decoration: BoxDecoration(
              color: cc.surface,
              borderRadius: BorderRadius.circular(rr(14)),
              border: Border.all(color: cc.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _InfoRow(
                  label: 'flight_number'.tr(),
                  value: flight?.flightNumber ?? '-',
                ),
                _InfoRow(
                  label: 'airline'.tr(),
                  value: flight?.airline ?? '-',
                ),
                _InfoRow(
                  label: 'stand_assignment'.tr(),
                  value: flight?.stand?.code ?? '-',
                ),
                _InfoRow(
                  label: 'aircraft_type'.tr(),
                  value: flight?.aircraftType ?? '-',
                ),
                _InfoRow(
                  label: 'pax_count'.tr(),
                  value: flight?.paxCount != null
                      ? '${flight!.paxCount}'
                      : '-',
                ),
                _InfoRow(
                  label: 'scheduled_arrival'.tr(),
                  value: flight?.scheduledArrival.formattedTime ?? '-',
                ),
                if (flight?.scheduledDeparture != null)
                  _InfoRow(
                    label: 'scheduled_departure'.tr(),
                    value: flight!.scheduledDeparture!.formattedTime,
                    isLast: true,
                  )
                else
                  _InfoRow(
                    label: 'priority'.tr(),
                    value: task.priority.label,
                    isLast: true,
                  ),
              ],
            ),
          ),
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            verticalSpacing(16),
            _SectionTitle(title: 'notes'.tr()),
            verticalSpacing(10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(rw(16)),
              decoration: BoxDecoration(
                color: cc.surface,
                borderRadius: BorderRadius.circular(rr(14)),
                border: Border.all(color: cc.border.withValues(alpha: 0.5)),
              ),
              child: Text(
                task.notes!,
                style: AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
              ),
            ),
          ],
          if (checklist.isNotEmpty) ...[
            verticalSpacing(16),
            _SectionTitle(title: 'checklist'.tr()),
            verticalSpacing(10),
            Container(
              decoration: BoxDecoration(
                color: cc.surface,
                borderRadius: BorderRadius.circular(rr(14)),
                border: Border.all(color: cc.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: checklist
                    .map((item) => _ChecklistItem(item: item))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Unit & Crew Section ──────────────────────────────────────────────────────

class _UnitCrewSection extends StatelessWidget {
  const _UnitCrewSection({
    required this.task,
    required this.isUpdating,
    required this.onUpdateStatus,
  });

  final TaskModel task;
  final bool isUpdating;
  final void Function(String newStatus) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final unit = task.unit;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unit != null) ...[
            _SectionTitle(title: 'assigned_unit'.tr()),
            verticalSpacing(10),
            _UnitCard(unit: unit),
            if (unit.members.isNotEmpty) ...[
              verticalSpacing(16),
              _SectionTitle(title: 'crew_members'.tr()),
              verticalSpacing(10),
              ...unit.members.map((m) => _CrewMemberTile(member: m)),
            ],
          ] else ...[
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: rh(24)),
                child: Text(
                  'no_unit_assigned'.tr(),
                  style: AppTextStyles.font14Light
                      .copyWith(color: cc.textSecondary),
                ),
              ),
            ),
          ],
          verticalSpacing(24),
          _SectionTitle(title: 'actions'.tr()),
          verticalSpacing(10),
          _ActionButtons(
            task: task,
            isUpdating: isUpdating,
            onUpdateStatus: onUpdateStatus,
          ),
        ],
      ),
    );
  }
}

// ─── Private Widgets ──────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = TaskUiHelpers.priorityColor(priority);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(8)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        priority.label,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = TaskUiHelpers.statusColor(status, context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(rr(8)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(5)),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: rf(13)),
          horizontalSpacing(5),
          Text(
            label,
            style: AppTextStyles.font12SemiBold.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.label,
    required this.time,
    required this.subLabel,
    this.highlight = false,
  });

  final String label;
  final String time;
  final String subLabel;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.font12Light.copyWith(
            color: AppColors.white,
            fontSize: 10,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpacing(4),
        Text(
          time,
          style: AppTextStyles.font18ExtraBold.copyWith(
            color: highlight ? AppColors.green200 : AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpacing(2),
        Text(
          subLabel,
          style: AppTextStyles.font12Light.copyWith(
            color: AppColors.white.withValues(alpha: 0.6),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: rh(12)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary200 : cc.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary200
                : cc.border.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: rf(16),
              color: isSelected ? Colors.white : cc.textSecondary,
            ),
            horizontalSpacing(6),
            Text(
              label,
              style: AppTextStyles.font14SemiBold.copyWith(
                color: isSelected ? Colors.white : cc.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.font16ExtraBold.copyWith(
        color: context.customColors.textPrimary,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: rh(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style:
                    AppTextStyles.font14Light.copyWith(color: cc.textSecondary),
              ),
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.font14SemiBold
                      .copyWith(color: cc.textPrimary),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: cc.border.withValues(alpha: 0.4)),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.item});

  final TaskCheckListModel item;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(10)),
      child: Row(
        children: [
          Icon(
            item.isChecked
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: rf(20),
            color: item.isChecked ? AppColors.green200 : cc.iconSecondary,
          ),
          horizontalSpacing(12),
          Expanded(
            child: Text(
              item.item,
              style: AppTextStyles.font14Light.copyWith(
                color: item.isChecked ? cc.textSecondary : cc.textPrimary,
                decoration: item.isChecked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit});

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final statusColor = _unitStatusColor(unit.status);

    return Container(
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(14)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: rw(44),
            height: rw(44),
            decoration: BoxDecoration(
              color: AppColors.primary200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(12)),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: AppColors.primary200,
              size: rf(22),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: AppTextStyles.font16SemiBold
                      .copyWith(color: cc.textPrimary),
                ),
                verticalSpacing(2),
                Text(
                  unit.shiftLabel,
                  style: AppTextStyles.font12Light
                      .copyWith(color: cc.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rr(8)),
            ),
            child: Text(
              unit.status,
              style:
                  AppTextStyles.font12SemiBold.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _unitStatusColor(String status) {
    return switch (status) {
      'available' => AppColors.green200,
      'busy' => AppColors.amber200,
      'offline' => AppColors.grey200,
      _ => AppColors.red200,
    };
  }
}

class _CrewMemberTile extends StatelessWidget {
  const _CrewMemberTile({required this.member});

  final UnitMemberModel member;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final initials = _initials(member.fullName);

    return Container(
      margin: EdgeInsets.only(bottom: rh(8)),
      padding: EdgeInsets.all(rw(12)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(12)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: rw(20),
            backgroundColor: AppColors.primary200.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: AppTextStyles.font14ExtraBold
                  .copyWith(color: AppColors.primary200),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: AppTextStyles.font14SemiBold
                      .copyWith(color: cc.textPrimary),
                ),
                Text(
                  member.position,
                  style: AppTextStyles.font12Light
                      .copyWith(color: cc.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            width: rw(8),
            height: rw(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: member.isActive ? AppColors.green200 : AppColors.grey200,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.task,
    required this.isUpdating,
    required this.onUpdateStatus,
  });

  final TaskModel task;
  final bool isUpdating;
  final void Function(String) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final status = task.status ?? TaskStatus.pending;

    return Column(
      children: [
        if (status == TaskStatus.pending || status == TaskStatus.assigned) ...[
          _ActionButton(
            label: 'mark_in_progress'.tr(),
            icon: Icons.play_arrow_outlined,
            color: AppColors.primary200,
            isLoading: isUpdating,
            onTap: () => onUpdateStatus(TaskStatus.inProgress.value),
          ),
          verticalSpacing(10),
        ],
        if (status == TaskStatus.inProgress) ...[
          _ActionButton(
            label: 'mark_paused'.tr(),
            icon: Icons.pause_outlined,
            color: AppColors.amber200,
            isLoading: isUpdating,
            onTap: () => onUpdateStatus(TaskStatus.paused.value),
          ),
          verticalSpacing(10),
          _ActionButton(
            label: 'mark_completed'.tr(),
            icon: Icons.check_circle_outline,
            color: AppColors.green200,
            isLoading: isUpdating,
            onTap: () => onUpdateStatus(TaskStatus.completed.value),
          ),
          verticalSpacing(10),
        ],
        if (status == TaskStatus.paused) ...[
          _ActionButton(
            label: 'mark_in_progress'.tr(),
            icon: Icons.play_arrow_outlined,
            color: AppColors.primary200,
            isLoading: isUpdating,
            onTap: () => onUpdateStatus(TaskStatus.inProgress.value),
          ),
          verticalSpacing(10),
        ],
        if (status != TaskStatus.completed &&
            status != TaskStatus.cancelled) ...[
          _ActionButton(
            label: 'mark_cancelled'.tr(),
            icon: Icons.cancel_outlined,
            color: AppColors.red200,
            isLoading: isUpdating,
            onTap: () => onUpdateStatus(TaskStatus.cancelled.value),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: rh(14)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: rw(20),
                  height: rw(20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: rf(18)),
                  horizontalSpacing(8),
                  Text(
                    label,
                    style:
                        AppTextStyles.font14SemiBold.copyWith(color: color),
                  ),
                ],
              ),
      ),
    );
  }
}
