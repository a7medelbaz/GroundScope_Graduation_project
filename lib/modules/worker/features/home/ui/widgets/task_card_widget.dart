import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions.dart';
import '../../../task_details_screen.dart';
import '../../data/models/task_model.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final bool showConnector;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.showConnector = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushSlideUp(
          TaskDetailsScreen(
            taskTitle: task.title,
            taskStatus: task.statusLabel,
            timeRange: task.timeRange,
            aircraftInfo: task.aircraftInfo,
            progress: task.progress,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTaskCardContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIcon() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: task.iconBackgroundColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(task.icon, color: task.iconColor, size: 24),
        ),
        if (showConnector)
          Container(
            width: 2,
            height: 36,
            margin: const EdgeInsets.only(top: 4),
            color: Colors.white24,
          ),
      ],
    );
  }

  Widget _buildTaskCardContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 343),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D141B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskHeader(),
            const SizedBox(height: 12),
            _buildTaskTimeInfo(),
            const SizedBox(height: 12),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: task.status.chipColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            task.statusLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTimeInfo() {
    return Text(
      '${task.timeRange} | ${task.aircraftInfo}',
      style: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 14,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        if (task.progress != null && task.progress! > 0)
          Text(
            '${task.progress} %',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (task.progress != null && task.progress! > 0)
          const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              minHeight: 6,
              backgroundColor: Colors.white24,
              value: (task.progress ?? 0) / 100,
              valueColor: AlwaysStoppedAnimation<Color>(task.status.progressColor),
            ),
          ),
        ),
      ],
    );
  }
}

