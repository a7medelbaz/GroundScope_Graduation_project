import 'package:flutter/material.dart';
import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/shared/data/models/task_pause_model.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/model/task_time_line_model.dart';

import 'task_timeline_row.dart';

class TaskActivityTimeline extends StatelessWidget {
  const TaskActivityTimeline({
    super.key,
    required this.task,
    required this.pauses,
  });

  final TaskModel task;
  final List<TaskPauseModel> pauses;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final events = TaskTimelineModel.buildFrom(task: task, pauses: pauses);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Empty state ──────────────────────────────────
        if (events.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: rh(24)),
              child: Text(
                'No activity recorded yet',
                style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
              ),
            ),
          )
        // ── Timeline rows ────────────────────────────────
        else
          ...events.asMap().entries.map((entry) {
            return TaskTimelineRow(
              event: entry.value,
              isLast: entry.key == events.length - 1,
            );
          }),
      ],
    );
  }
}
