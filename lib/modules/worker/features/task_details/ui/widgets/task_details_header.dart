import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/string_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../../../../../core/utils/task_ui_helpers.dart';

class TaskDetailsHeader extends StatelessWidget {
  const TaskDetailsHeader({
    super.key,
    required this.task,
    required this.onBackButtonPressed,
  });
  final TaskModel task;
  final VoidCallback onBackButtonPressed;

  IconData get _serviceIcon => switch (task.serviceTypeName?.toLowerCase()) {
    'fuel' => Icons.local_gas_station_rounded,
    'cleaning' => Icons.cleaning_services_rounded,
    'catering' => Icons.restaurant_rounded,
    'maintenance' => Icons.build_rounded,
    'baggage' => Icons.luggage_rounded,
    _ => Icons.miscellaneous_services_rounded,
  };

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final statusColor = TaskUiHelpers.statusColor(task.status!, context);
    final priorityColor = TaskUiHelpers.priorityColor(task.priority);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary400,
            AppColors.primary300,
            AppColors.primary200,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(rr(28)),
          bottomRight: Radius.circular(rr(28)),
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
          Row(
            children: [
              GestureDetector(
                onTap: () => onBackButtonPressed(),
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
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(10),
                  vertical: rh(5),
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(rr(20)),
                  border: Border.all(
                    color: priorityColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: rw(6),
                      height: rw(6),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    horizontalSpacing(5),
                    Text(
                      task.priority.label.toUpperCase(),
                      style: AppTextStyles.font12SemiBold.copyWith(
                        color: priorityColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(20),
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
                child: Icon(_serviceIcon, color: AppColors.white, size: rf(26)),
              ),
              horizontalSpacing(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${task.flightNumber ?? ''} '.trim(),
                      style: AppTextStyles.font22ExtraBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    verticalSpacing(4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(10),
                        vertical: rh(3),
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(rr(20)),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        task.status!.label.toUpperCase(),
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          verticalSpacing(20),

          Container(height: 1, color: AppColors.white.withValues(alpha: 0.15)),
          verticalSpacing(16),

          Row(
            children: [
              _InfoPill(
                icon: Icons.flight_rounded,
                label: task.serviceTypeName?.capitalize() ?? '—',
              ),
              horizontalSpacing(10),
              if (task.standCode != null)
                _InfoPill(
                  icon: Icons.location_on_rounded,
                  label: 'worker_task_details.stand'
                      .tr(namedArgs: {'code': task.standCode!}),
                ),
              const Spacer(),
              _InfoPill(
                icon: Icons.timer_outlined,
                label: 'worker_task_details.duration_min'
                    .tr(namedArgs: {'minutes': '${task.durationMinutes}'}),
              ),
            ],
          ),

          verticalSpacing(16),

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
                    time: _fmt(task.scheduledStart),
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
                    time: _fmt(task.scheduledEnd),
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
                      label: 'worker_task_details.actual_start'.tr(),
                      time: _fmt(task.actualStart!),
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
}

// ── Info pill ─────────────────────────────────────────────────

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
          Icon(icon, color: AppColors.primary50, size: rf(13)),
          horizontalSpacing(5),
          Text(
            label,
            style: AppTextStyles.font12SemiBold.copyWith(
              color: AppColors.white,
            ),
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
      ],
    );
  }
}
