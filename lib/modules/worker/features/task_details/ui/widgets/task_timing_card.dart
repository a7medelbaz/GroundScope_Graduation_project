import 'package:flutter/material.dart';
import '../../../../../../core/data/models/task_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/widgets/info_card.dart';
import '../../../../../../core/widgets/info_row_data.dart';
import '../task_info_screen.dart';

class TaskTimingCard extends StatelessWidget {
  const TaskTimingCard({super.key, required this.task});
  final TaskModel task;

  static String _fmt(DateTime? dt) => TaskInfoScreen.fmt(dt);

  @override
  Widget build(BuildContext context) {
    final startDelay = task.actualStart
        ?.difference(task.scheduledStart)
        .inMinutes;

    return InfoCard(
      rows: [
        InfoRowData(
          icon: Icons.schedule_rounded,
          label: 'Scheduled Start',
          value: _fmt(task.scheduledStart),
        ),
        InfoRowData(
          icon: Icons.schedule_rounded,
          label: 'Scheduled End',
          value: _fmt(task.scheduledEnd),
        ),
        if (task.actualStart != null)
          InfoRowData(
            icon: Icons.play_arrow_rounded,
            label: 'Actual Start',
            value: _fmt(task.actualStart),
            highlight: true,
          ),
        if (startDelay != null)
          InfoRowData(
            icon: startDelay > 0
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            label: 'Start Delay',
            value: startDelay == 0
                ? 'On time'
                : startDelay > 0
                ? '+$startDelay min late'
                : '${startDelay.abs()} min early',
            valueColor: startDelay > 5
                ? AppColors.red200
                : startDelay > 0
                ? AppColors.amber200
                : AppColors.green200,
          ),
        if (task.actualEnd != null)
          InfoRowData(
            icon: Icons.check_rounded,
            label: 'Actual End',
            value: _fmt(task.actualEnd),
            highlight: true,
          ),
      ],
    );
  }
}
