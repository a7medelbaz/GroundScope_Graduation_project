import 'package:flutter/material.dart';
import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/core/widgets/section_label.dart';
import 'package:ground_scope/modules/worker/features/task_details/data/models/task_pause_model.dart';
import 'package:ground_scope/modules/worker/features/task_details/data/models/task_time_line_model.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/widgets/task_activity_timeline.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/widgets/task_flight_details_card.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/widgets/task_stand_details_card.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/widgets/task_timing_card.dart';

class TaskInfoScreen extends StatelessWidget {
  const TaskInfoScreen({super.key, required this.task, required this.pauses});

  final TaskModel task;
  final List<TaskPauseModel> pauses;

  // ── helpers ──────────────────────────────────────────────────

  static String fmt(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  // Build the unified activity timeline events
  List<TaskTimelineModel> _buildTimeline() {
    final events = <TaskTimelineModel>[];

    // Task assigned / created
    events.add(
      TaskTimelineModel(
        time: task.createdAt,
        label: 'Task Created',
        sublabel: 'Assigned to unit',
        icon: Icons.assignment_rounded,
        color: AppColors.blue200,
        type: EventType.system,
      ),
    );

    // Actual start
    if (task.actualStart != null) {
      events.add(
        TaskTimelineModel(
          time: task.actualStart!,
          label: 'Task Started',
          sublabel: 'Unit began execution',
          icon: Icons.play_arrow_rounded,
          color: AppColors.primary200,
          type: EventType.action,
        ),
      );
    }

    // Pauses (interleaved by time)
    for (final p in pauses) {
      events.add(
        TaskTimelineModel(
          time: p.pausedAt,
          label: 'Task Paused',
          sublabel: p.reason ?? 'No reason provided',
          icon: Icons.pause_rounded,
          color: AppColors.amber200,
          type: EventType.pause,
        ),
      );
      if (p.resumedAt != null) {
        events.add(
          TaskTimelineModel(
            time: p.resumedAt!,
            label: 'Task Resumed',
            sublabel: 'Paused for ${p.duration.inMinutes} min',
            icon: Icons.play_circle_outline_rounded,
            color: AppColors.primary200,
            type: EventType.action,
          ),
        );
      }
    }

    // Actual end
    if (task.actualEnd != null) {
      events.add(
        TaskTimelineModel(
          time: task.actualEnd!,
          label: 'Task Completed',
          sublabel: 'All steps finished',
          icon: Icons.check_circle_rounded,
          color: AppColors.green200,
          type: EventType.complete,
        ),
      );
    }

    // Sort by time
    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final timeline = _buildTimeline();

    return Scaffold(
      backgroundColor: cc.background,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────
          _TaskInfoHeader(task: task),

          // ── Body ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flight details
                  const SectionLabel(
                    title: 'Flight Details',
                    color: AppColors.primary200,
                  ),
                  verticalSpacing(12),
                  TaskFlightDetailsCard(task: task),

                  verticalSpacing(24),

                  // Stand details
                  const SectionLabel(
                    title: 'Stand Details',
                    color: AppColors.primary200,
                  ),
                  verticalSpacing(12),
                  TaskStandDetailsCard(task: task),

                  verticalSpacing(24),

                  // Task timing
                  const SectionLabel(
                    title: 'Task Timing',
                    color: AppColors.primary200,
                  ),
                  verticalSpacing(12),
                  TaskTimingCard(task: task),

                  verticalSpacing(24),

                  // Activity timeline
                  const SectionLabel(
                    title: 'Activity Timeline',
                    color: AppColors.amber200,
                  ),
                  verticalSpacing(16),
                  TaskActivityTimeline(events: timeline),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────

class _TaskInfoHeader extends StatelessWidget {
  const _TaskInfoHeader({required this.task});
  final TaskModel task;

  IconData get _serviceIcon => switch (task.serviceTypeName?.toLowerCase()) {
    'fuel' => Icons.local_gas_station_rounded,
    'cleaning' => Icons.cleaning_services_rounded,
    'catering' => Icons.restaurant_rounded,
    'maintenance' => Icons.build_rounded,
    'baggage' => Icons.luggage_rounded,
    _ => Icons.miscellaneous_services_rounded,
  };

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
        top: rh(56),
        bottom: rh(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: rw(38),
                  height: rw(38),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Info',
                      style: AppTextStyles.font18ExtraBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      task.serviceTypeName ?? 'Ground Service',
                      style: AppTextStyles.font12Light.copyWith(
                        color: AppColors.primary100,
                      ),
                    ),
                  ],
                ),
              ),
              // Service icon box
              Container(
                width: rw(46),
                height: rw(46),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(rr(12)),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(_serviceIcon, color: AppColors.white, size: rf(22)),
              ),
            ],
          ),

          verticalSpacing(20),

          // Quick stat pills row
          Row(
            children: [
              _QuickPill(
                icon: Icons.flight_rounded,
                label: task.flightNumber ?? '—',
              ),
              horizontalSpacing(8),
              if (task.standCode != null) ...[
                _QuickPill(
                  icon: Icons.location_on_rounded,
                  label: 'Stand ${task.standCode}',
                ),
                horizontalSpacing(8),
              ],
              _QuickPill(
                icon: Icons.timer_outlined,
                label: '${task.durationMinutes} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickPill extends StatelessWidget {
  const _QuickPill({required this.icon, required this.label});
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
          Icon(icon, color: AppColors.primary50, size: rf(12)),
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
