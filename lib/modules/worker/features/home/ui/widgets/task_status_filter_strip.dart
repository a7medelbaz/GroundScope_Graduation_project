import 'package:flutter/material.dart';
import '../../../../../../core/data/models/task_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import 'task_status_chip.dart';

class TaskStatusFilterStrip extends StatelessWidget {
  const TaskStatusFilterStrip({
    super.key,
    required this.tasks,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final List<TaskModel> tasks;
  final TaskStatus? selectedStatus;
  final ValueChanged<TaskStatus?> onStatusChanged;

  int _count(TaskStatus s) => tasks.where((t) => t.status == s).length;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return SizedBox(
      height: rh(64),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: rw(16)),
        children: [
          TaskStatusChip(
            label: 'All',
            count: tasks.length,
            color: cc.textSecondary,
            isSelected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
          ),
          horizontalSpacing(8),
          TaskStatusChip(
            label: 'In Progress',
            count: _count(TaskStatus.inProgress),
            color: AppColors.primary200,
            isSelected: selectedStatus == TaskStatus.inProgress,
            onTap: () => onStatusChanged(
              selectedStatus == TaskStatus.inProgress
                  ? null
                  : TaskStatus.inProgress,
            ),
          ),
          horizontalSpacing(8),
          TaskStatusChip(
            label: 'Pending',
            count: _count(TaskStatus.pending),
            color: AppColors.amber200,
            isSelected: selectedStatus == TaskStatus.pending,
            onTap: () => onStatusChanged(
              selectedStatus == TaskStatus.pending ? null : TaskStatus.pending,
            ),
          ),
          horizontalSpacing(8),
          TaskStatusChip(
            label: 'Assigned',
            count: _count(TaskStatus.assigned),
            color: AppColors.blue200,
            isSelected: selectedStatus == TaskStatus.assigned,
            onTap: () => onStatusChanged(
              selectedStatus == TaskStatus.assigned
                  ? null
                  : TaskStatus.assigned,
            ),
          ),
          horizontalSpacing(8),
          TaskStatusChip(
            label: 'Done',
            count: _count(TaskStatus.completed),
            color: AppColors.green200,
            isSelected: selectedStatus == TaskStatus.completed,
            onTap: () => onStatusChanged(
              selectedStatus == TaskStatus.completed
                  ? null
                  : TaskStatus.completed,
            ),
          ),
        ],
      ),
    );
  }
}
