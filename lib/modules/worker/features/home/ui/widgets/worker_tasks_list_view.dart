import 'package:flutter/material.dart';
import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

import 'list_view_task_card.dart';
import 'task_list_empty_state.dart';
import 'task_status_filter_strip.dart';

class WorkerTasksListView extends StatefulWidget {
  const WorkerTasksListView({
    super.key,
    required this.tasks,
    required this.onRefresh,
  });

  final List<TaskModel> tasks;
  final Future<void> Function() onRefresh;

  @override
  State<WorkerTasksListView> createState() => _WorkerTasksListViewState();
}

class _WorkerTasksListViewState extends State<WorkerTasksListView> {
  TaskStatus? _selectedStatus; // null = show all

  List<TaskModel> get _filteredTasks => _selectedStatus == null
      ? widget.tasks
      : widget.tasks.where((t) => t.status == _selectedStatus).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks;
    final cc = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status filter strip (reusable)
        TaskStatusFilterStrip(
          tasks: widget.tasks,
          selectedStatus: _selectedStatus,
          onStatusChanged: (status) => setState(() => _selectedStatus = status),
        ),

        verticalSpacing(24),

        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(16)),
          child: Row(
            children: [
              Text(
                "Today's Tasks",
                style: AppTextStyles.font18ExtraBold.copyWith(
                  color: cc.textPrimary,
                ),
              ),
              horizontalSpacing(6),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(8),
                  vertical: rh(2),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary200.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(rr(20)),
                ),
                child: Text(
                  '${filtered.length}',
                  style: AppTextStyles.font12ExtraBold.copyWith(
                    color: AppColors.primary200,
                  ),
                ),
              ),
            ],
          ),
        ),

        verticalSpacing(24),

        // Scrollable task list with proper RefreshIndicator
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            backgroundColor: AppColors.white,
            color: AppColors.primary300,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: TaskListEmptyState(status: _selectedStatus),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(16),
                    ).copyWith(bottom: rh(24)),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = filtered[index];
                        return GestureDetector(
                          onTap: () => context.pushNamed(
                            rootNavigator: true,
                            Routes.taskDetailsScreen,
                            arguments: {'task': task},
                          ),
                          child: TaskCard(
                            task: task,
                            index: index,
                            isLast: index == filtered.length - 1,
                          ),
                        );
                      }, childCount: filtered.length),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
