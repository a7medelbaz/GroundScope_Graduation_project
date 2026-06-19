import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/router/routes.dart';
import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../logic/cubit/home_cubit.dart';
import 'list_view_task_card.dart';
import 'task_list_empty_state.dart';
import 'task_status_filter_strip.dart';

class WorkerTasksListView extends StatefulWidget {
  const WorkerTasksListView({super.key, required this.tasks});

  final List<TaskModel> tasks;

  @override
  State<WorkerTasksListView> createState() => _WorkerTasksListViewState();
}

class _WorkerTasksListViewState extends State<WorkerTasksListView> {
  TaskStatus? _selectedStatus;

  List<TaskModel> get _filteredTasks {
    if (_selectedStatus == null) return widget.tasks;

    return widget.tasks.where((t) => t.status == _selectedStatus).toList();
  }

  Future<void> _openTaskDetails(TaskModel task) async {
    final result = await context.pushNamed(
      rootNavigator: true,
      Routes.taskDetailsScreen,
      arguments: {'task': task},
    );

    if (result == true && mounted) {
      context.read<HomeCubit>().init();
    }
  }

  void _onStatusChanged(TaskStatus? status) {
    setState(() => _selectedStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    final colors = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterStrip(),
        verticalSpacing(24),
        _buildHeader(filteredTasks.length, colors),
        verticalSpacing(24),
        _buildTaskList(filteredTasks),
      ],
    );
  }

  Widget _buildFilterStrip() {
    return TaskStatusFilterStrip(
      tasks: widget.tasks,
      selectedStatus: _selectedStatus,
      onStatusChanged: _onStatusChanged,
    );
  }

  Widget _buildHeader(int count, dynamic colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16)),
      child: Row(
        children: [
          Text(
            'worker_home.todays_tasks'.tr(),
            style: AppTextStyles.font18ExtraBold.copyWith(
              color: colors.textPrimary,
            ),
          ),
          horizontalSpacing(6),
          _buildCountBadge(count),
        ],
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(2)),
      decoration: BoxDecoration(
        color: AppColors.primary200.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rr(20)),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.font12ExtraBold.copyWith(
          color: AppColors.primary200,
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    return Expanded(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (tasks.isEmpty) _buildEmptyState() else _buildSliverList(tasks),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: TaskListEmptyState(status: _selectedStatus),
    );
  }

  Widget _buildSliverList(List<TaskModel> tasks) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(16),
      ).copyWith(bottom: rh(24)),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final task = tasks[index];

          return GestureDetector(
            onTap: () => _openTaskDetails(task),
            child: TaskCard(
              task: task,
              index: index,
              isLast: index == tasks.length - 1,
            ),
          );
        }, childCount: tasks.length),
      ),
    );
  }
}
