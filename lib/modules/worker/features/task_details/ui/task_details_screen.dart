import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/router/routes.dart';
import '../../../../../core/shared/data/models/task_model.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../../../core/widgets/ui/dialogs/app_dialogs.dart';
import '../logic/cubit/task_details_cubit.dart';
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
  late TaskDetailsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<TaskDetailsCubit>();
    cubit.initTask(task: widget.task);
  }

  void _popWithResult() {
    context.pop(true);
  }

  Future<void> _onBack(TaskDetailsState state) async {
    if (state.status == TaskStatus.inProgress) {
      await AppDialogs.showConfirm(
        context,
        title: 'Finish Task?',
        message: 'Do you want to mark this task as completed before leaving?',
        confirmText: 'Finish',
        cancelText: 'Stay',
        onConfirm: () {
          _popWithResult();
        },
      );
    } else {
      _popWithResult();
    }
  }

  Future<void> _onStart() async {
    await cubit.updateTaskStatus(
      taskId: widget.task.id,
      newStatus: TaskStatus.inProgress,
    );
  }

  Future<void> _onResume() async {
    await cubit.resumeTask(widget.task.id);
  }

  Future<void> _onPause() async {
    final reason = await PauseReasonBottomSheet.show(context);
    if (reason == null || reason.trim().isEmpty) return;
    await cubit.pauseTask(taskId: widget.task.id, reason: reason.trim());
  }

  Future<void> _onComplete(TaskDetailsState state) async {
    final allChecked = state.checklist.every((e) => e.isChecked);
    Future<void> complete() async {
      await cubit.updateTaskStatus(
        taskId: widget.task.id,
        newStatus: TaskStatus.completed,
      );
      _popWithResult();
    }

    if (!allChecked && state.status == TaskStatus.inProgress) {
      AppDialogs.showConfirm(
        context,
        title: 'Checklist Incomplete',
        message: 'Finish task anyway?',
        confirmText: 'Finish',
        cancelText: 'Cancel',
        onConfirm: complete,
      );
      return;
    }

    await complete();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskDetailsCubit, TaskDetailsState>(
      listener: (context, state) {
        if (state.error != null) {
          context.showSnackBar(state.error!.messageKey);
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.checklist.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final task = widget.task.copyWith(status: state.status);

        return Scaffold(
          backgroundColor: context.customColors.background,
          extendBodyBehindAppBar: true,
          body: Column(
            children: [
              TaskDetailsHeader(
                task: task,
                onBackButtonPressed: () => _onBack(state),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(140)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActions(task, state),
                      verticalSpacing(24),
                      TaskDetailsTaskMetaSection(task: task),
                      verticalSpacing(24),
                      _buildChecklist(state),
                      verticalSpacing(24),
                      _buildNotes(task),
                      verticalSpacing(24),
                      _buildPauseHistory(state),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildActions(state),
        );
      },
    );
  }

  Widget _buildQuickActions(TaskModel task, TaskDetailsState state) {
    return TaskDetailsQuickActionsRow(
      onInfoTap: () => context.pushNamed(
        Routes.taskDetailsInfoScreen,
        arguments: {'task': task, 'pauses': state.pauses},
      ),
      onReportTap: () =>
          context.pushNamed(Routes.addReportScreen, arguments: {'preSelectedTask': task}),
      taskStatus: state.status!,
    );
  }

  Widget _buildPauseHistory(TaskDetailsState state) {
    if (state.pauses.isEmpty) return const SizedBox.shrink();
    return TaskDetailsPauseHistorySection(pauses: state.pauses);
  }

  Widget _buildChecklist(TaskDetailsState state) {
    return TaskDetailsChecklist(
      items: state.checklist,
      taskStatus: state.status!,
      onToggle: (item) {
        cubit.updateChecklistItem(itemId: item.id, isChecked: !item.isChecked);
      },
    );
  }

  Widget _buildNotes(TaskModel task) {
    if (task.notes?.isEmpty ?? true) return const SizedBox.shrink();
    return TaskDetailsNotesSection(notes: task.notes!);
  }

  Widget? _buildActions(TaskDetailsState state) {
    if (state.status == TaskStatus.completed ||
        state.status == TaskStatus.cancelled) {
      return null;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(rw(20), rh(16), rw(20), rh(32)),
      decoration: BoxDecoration(color: context.customColors.background),
      child: TaskActionButton(
        status: state.status,
        onStart: _onStart,
        onPause: _onPause,
        onResume: _onResume,
        onComplete: () => _onComplete(state),
      ),
    );
  }
}
