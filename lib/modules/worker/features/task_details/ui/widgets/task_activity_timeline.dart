import 'package:flutter/material.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/models/task_time_line_model.dart';
import 'task_timeline_row.dart';

class TaskActivityTimeline extends StatelessWidget {
  const TaskActivityTimeline({super.key, required this.events});
  final List<TaskTimelineModel> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: rh(24)),
          child: Text(
            'No activity recorded yet',
            style: AppTextStyles.font14Light.copyWith(
              color: context.customColors.textHint,
            ),
          ),
        ),
      );
    }

    return Column(
      children: events.asMap().entries.map((entry) {
        final isLast = entry.key == events.length - 1;
        final event = entry.value;
        return TaskTimelineRow(event: event, isLast: isLast);
      }).toList(),
    );
  }
}
