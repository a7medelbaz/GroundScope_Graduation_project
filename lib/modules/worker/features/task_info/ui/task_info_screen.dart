import 'package:flutter/material.dart';
import 'widgets/task_info_header.dart';
import '../../../../../core/shared/data/models/task_model.dart';
import '../../../../../core/shared/data/models/task_pause_model.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../core/widgets/section_label.dart';
import 'widgets/task_activity_timeline.dart';
import 'widgets/task_flight_details_card.dart';
import 'widgets/task_stand_details_card.dart';
import 'widgets/task_timing_card.dart';

class TaskInfoScreen extends StatelessWidget {
  const TaskInfoScreen({super.key, required this.task, required this.pauses});

  final TaskModel task;
  final List<TaskPauseModel> pauses;

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

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
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
                  TaskActivityTimeline(task: task, pauses: pauses),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
