import 'package:flutter/material.dart';
import 'package:ground_scope/modules/worker/features/task_info/ui/widgets/task_info_header.dart';

import '../../../../../core/shared/data/models/task_model.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../core/widgets/section_label.dart';
import '../../task_details/data/models/task_pause_model.dart';
import '../../task_details/data/models/task_time_line_model.dart';
import 'widgets/task_activity_timeline.dart';
import 'widgets/task_flight_details_card.dart';
import 'widgets/task_stand_details_card.dart';
import 'widgets/task_timing_card.dart';

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
          TaskInfoHeader(task: task),
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
