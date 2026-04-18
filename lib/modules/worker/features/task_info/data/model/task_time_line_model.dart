// lib/modules/worker/features/task_info/data/model/task_time_line_model.dart

import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/task_pause_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';

enum EventType { system, action, pause, resume, complete }

class TaskTimelineModel {
  const TaskTimelineModel({
    required this.time,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.type,
    this.secondaryTime,
  });

  final DateTime time;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final EventType type;

  /// Only set on [EventType.resume] — holds the paused-at time
  /// so the row can display both "paused at X → resumed at Y".
  final DateTime? secondaryTime;

  static List<TaskTimelineModel> buildFrom({
    required TaskModel task,
    required List<TaskPauseModel> pauses,
  }) {
    final events = <TaskTimelineModel>[];

    events.add(
      TaskTimelineModel(
        time: task.createdAt,
        label: 'Task Assigned',
        sublabel: 'Task created and assigned to unit',
        icon: Icons.assignment_rounded,
        color: AppColors.blue200,
        type: EventType.system,
      ),
    );

    if (task.actualStart != null) {
      events.add(
        TaskTimelineModel(
          time: task.actualStart!,
          label: 'Task Started',
          sublabel: _startDelaySublabel(task),
          icon: Icons.play_arrow_rounded,
          color: AppColors.primary200,
          type: EventType.action,
        ),
      );
    }

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
        final pausedFor = p.duration.inMinutes;
        events.add(
          TaskTimelineModel(
            time: p.resumedAt!,
            label: 'Task Resumed',
            sublabel: pausedFor == 0
                ? 'Resumed immediately'
                : 'Paused for $pausedFor min',
            icon: Icons.play_circle_outline_rounded,
            color: AppColors.primary200,
            type: EventType.resume,
            secondaryTime: p.pausedAt,
          ),
        );
      }
    }

    if (task.actualEnd != null) {
      events.add(
        TaskTimelineModel(
          time: task.actualEnd!,
          label: 'Task Completed',
          sublabel: _completionSublabel(task),
          icon: Icons.check_circle_rounded,
          color: AppColors.green200,
          type: EventType.complete,
        ),
      );
    }

    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  static String _startDelaySublabel(TaskModel task) {
    if (task.actualStart == null) return 'Unit began execution';
    final delay = task.actualStart!.difference(task.scheduledStart).inMinutes;
    if (delay <= 0) return 'Started on time';
    if (delay <= 5) return 'Started $delay min late';
    return 'Started $delay min late — delayed';
  }

  static String _completionSublabel(TaskModel task) {
    if (task.actualEnd == null || task.actualStart == null) {
      return 'All steps finished';
    }
    final total = task.actualEnd!.difference(task.actualStart!).inMinutes;
    return 'Completed in $total min';
  }
}
