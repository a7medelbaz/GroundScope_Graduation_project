import 'package:flutter/material.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/router/routes.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/models/task_filter_model.dart';
import 'filter_sheet/task_filter_bottom_sheet.dart';

import '../../data/models/task_model.dart';
import 'list_view_task_card.dart';

class WorkerTasksListView extends StatefulWidget {
  const WorkerTasksListView({super.key, required List<TaskModel> tasks})
    : _tasks = tasks;

  final List<TaskModel> _tasks;

  @override
  State<WorkerTasksListView> createState() => _WorkerTasksListViewState();
}

class _WorkerTasksListViewState extends State<WorkerTasksListView> {
  TaskFilter _filter = TaskFilter.empty;

  List<TaskModel> get _filteredTasks => widget._tasks.where((task) {
    final statusMatch = _filter.status == null || task.status == _filter.status;
    if (_filter.hours == null) return statusMatch;

    final startStr = task.timeRange.split(' - ').first.trim();
    final parts = startStr.split(':');
    final now = DateTime.now();
    final taskTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final timeMatch = now.difference(taskTime).inHours <= _filter.hours!;
    return statusMatch && timeMatch;
  }).toList();

  Future<void> _openFilter() async {
    final result = await TaskFilterBottomSheet.show(context, _filter);
    if (result != null) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks;

    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: responsiveWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Today's Tasks", style: AppTextStyles.font18Bold),
                horizontalSpacing(4),
                Text(
                  '[${filtered.length}]',
                  style: AppTextStyles.font14Regular.copyWith(
                    color: context.customColors.textSecondary,
                  ),
                ),
                const Spacer(),
                openFilterSheet(context),
              ],
            ),
            verticalSpacing(16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  context.pushNamed(
                    Routes.taskDetailsScreen,
                    arguments: {'task': filtered[index]},
                  );
                },
                child: TaskCard(
                  task: filtered[index],
                  isLast: index == filtered.length - 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector openFilterSheet(BuildContext context) {
    return GestureDetector(
      onTap: _openFilter,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(10),
          vertical: responsiveHeight(6),
        ),
        decoration: BoxDecoration(
          color: _filter.isActive
              ? context.customColors.accentBlue.withValues(alpha: 0.15)
              : context.customColors.divider.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(responsiveRadius(12)),
          border: Border.all(
            color: _filter.isActive
                ? context.customColors.accentBlue
                : context.customColors.divider,
          ),
        ),
        child: Icon(
          Icons.tune_rounded,
          color: _filter.isActive
              ? context.customColors.accentBlue
              : context.customColors.textSecondary.withValues(alpha: 0.8),
          size: responsiveWidth(22),
        ),
      ),
    );
  }
}
