import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import 'task_card_widget.dart';

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;

  const TaskListWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Tasks",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ListView.separated(
          itemCount: tasks.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCardWidget(
              task: task,
              showConnector: true, // Always show connector for all tasks
            );
          },
        ),
      ],
    );
  }
}

