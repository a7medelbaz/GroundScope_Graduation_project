import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/modules/worker/features/task_details/logic/cubit/task_details_cubit.dart';

import '../../../../../core/router/routes.dart';
import '../../../../../core/shared/data/models/task_model.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../../../core/widgets/ui/dialogs/app_dialogs.dart';
import '../data/models/task_pause_model.dart';
import 'widgets/pause_reason_bottom_sheet.dart';
import 'widgets/task_action_button.dart';
import 'widgets/task_details_checklist.dart';
import 'widgets/task_details_header.dart';
import 'widgets/task_details_notes_section.dart';
import 'widgets/task_details_pause_history_section.dart';
import 'widgets/task_details_quick_actions_row.dart';
import 'widgets/task_details_task_meta_section.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.task});
  final TaskModel task;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TaskStatus _status;
  final List<TaskPauseModel> _pauses = [];

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;

    context.read<TaskDetailsCubit>().fetchTaskCheckList(taskId: widget.task.id);
  }

  void _onStart() => setState(() => _status = TaskStatus.inProgress);

  Future<void> _onPause() async {
    final reason = await PauseReasonBottomSheet.show(context);

    setState(() {
      _status = TaskStatus.paused;
      _pauses.add(
        TaskPauseModel(
          id: 'pause-${_pauses.length}',
          taskId: widget.task.id,
          pausedAt: DateTime.now(),
          reason: reason,
        ),
      );
    });
  }

  void _onResume() => setState(() => _status = TaskStatus.inProgress);

  void _onComplete(List<TaskCheckListModel> checklist) {
    final allChecked = checklist.every((i) => i.isChecked);

    if (!allChecked) {
      AppDialogs.showConfirm(
        context,
        title: 'Checklist Incomplete',
        message: 'Are you sure you want to finish the task?',
        onConfirm: () {
          setState(() => _status = TaskStatus.completed);
          context.pop();
          context.pop();
        },
        confirmText: 'Finish Anyway',
        cancelText: 'Go Back',
      );
      return;
    }

    setState(() => _status = TaskStatus.completed);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final task = widget.task;

    return BlocConsumer<TaskDetailsCubit, TaskDetailsState>(
      listener: (context, state) {
        if (state.error != null) {
          context.showSnackBar(state.error!.messageKey);
        }
      },
      builder: (context, state) {
        final checklist = state.checklist;
        if (state.isLoading && checklist.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: cc.background,
          extendBodyBehindAppBar: true,
          body: Column(
            children: [
              TaskDetailsHeader(
                task: task.copyWith(status: _status),
                onBackButtonPressed: _status == TaskStatus.inProgress
                    ? () => _onComplete(checklist)
                    : context.pop,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(120)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TaskDetailsQuickActionsRow(
                        onInfoTap: () => context.pushNamed(
                          Routes.taskDetailsInfoScreen,
                          arguments: {
                            'task': widget.task.copyWith(status: _status),
                            'pauses': _pauses,
                          },
                        ),
                        onReportTap: () =>
                            context.pushNamed(Routes.addReportScreen),
                        taskStatus: _status,
                      ),
                      verticalSpacing(24),
                      TaskDetailsTaskMetaSection(task: task),
                      verticalSpacing(24),
                      if (_pauses.isNotEmpty) ...[
                        TaskDetailsPauseHistorySection(pauses: _pauses),
                        verticalSpacing(24),
                      ],
                      TaskDetailsChecklist(
                        items: checklist,
                        taskStatus: _status,
                        onToggle: (item) {
                          context.read<TaskDetailsCubit>().updateChecklistItem(
                            itemId: item.id,
                            isChecked: !item.isChecked,
                          );
                        },
                      ),

                      verticalSpacing(24),

                      if (task.notes?.isNotEmpty ?? false)
                        TaskDetailsNotesSection(notes: task.notes!),
                    ],
                  ),
                ),
              ),
            ],
          ),

          bottomSheet:
              _status == TaskStatus.completed ||
                  _status == TaskStatus.cancelled ||
                  _status == TaskStatus.pending
              ? null
              : Container(
                  padding: EdgeInsets.fromLTRB(rw(20), rh(16), rw(20), rh(32)),
                  decoration: BoxDecoration(color: cc.background),
                  child: TaskActionButton(
                    status: _status,
                    onStart: _onStart,
                    onPause: _onPause,
                    onResume: _onResume,
                    onComplete: () => _onComplete(checklist),
                  ),
                ),
        );
      },
    );
  }
}
