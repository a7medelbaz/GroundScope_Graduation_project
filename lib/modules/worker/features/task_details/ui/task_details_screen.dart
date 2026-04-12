import 'package:flutter/material.dart';

import '../../../../../core/data/models/task_model.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../../../core/widgets/ui/dialogs/app_dialogs.dart';
import '../data/models/checklist_item_model.dart';
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
  late List<ChecklistItemModel> _checklist;
  final List<TaskPauseModel> _pauses = [];

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    _checklist = _mockChecklist();
  }

  List<ChecklistItemModel> _mockChecklist() {
    final serviceType = widget.task.serviceTypeName?.toLowerCase() ?? '';
    final items = switch (serviceType) {
      'fuel' => [
        'Connect fuel hose to aircraft',
        'Confirm fuel type with captain',
        'Begin fueling — monitor gauge',
        'Reach target fuel quantity',
        'Disconnect hose and secure caps',
        'Submit fuel log',
      ],
      'cleaning' => [
        'Remove all waste from cabin',
        'Wipe tray tables and armrests',
        'Vacuum all seat rows',
        'Clean lavatories',
        'Restock amenities',
        'Final walkthrough and sign-off',
      ],
      'baggage' => [
        'Position belt loader at cargo door',
        'Unload arriving baggage',
        'Sort baggage by destination',
        'Load departing baggage',
        'Secure cargo doors',
        'Submit baggage report',
      ],
      _ => [
        'Prepare equipment',
        'Execute service procedure',
        'Quality check',
        'Sign-off and report',
      ],
    };

    return items.asMap().entries.map((e) {
      final alreadyDone = e.key < widget.task.checklistDone;
      return ChecklistItemModel(
        id: 'mock-${e.key}',
        taskId: widget.task.id,
        item: e.value,
        isChecked: alreadyDone,
        checkedAt: alreadyDone ? DateTime.now() : null,
        orderIndex: e.key,
      );
    }).toList();
  }

  void _onStart() => setState(() => _status = TaskStatus.inProgress);

  Future<void> _onPause() async {
    final reason = await PauseReasonBottomSheet.show(context);
    if (reason != null || true) {
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
  }

  void _onResume() => setState(() => _status = TaskStatus.inProgress);

  void _onComplete() {
    final allChecked = _checklist.every((i) => i.isChecked);
    if (!allChecked) {
      AppDialogs.showConfirm(
        context,
        title: 'Checklist Incomplete',
        message: 'Are you sure you want to finish the task?',
        onConfirm: () {
          setState(() => _status = TaskStatus.completed);
          context.pop();
        },
        confirmText: 'Finish Anyway',
        cancelText: 'Go Back',
      );
      return;
    }
    setState(() => _status = TaskStatus.completed);
    Navigator.of(context).pop();
  }

  void _onChecklistToggle(ChecklistItemModel item) {
    setState(() {
      final index = _checklist.indexWhere((i) => i.id == item.id);
      _checklist[index] = item.copyWith(
        isChecked: !item.isChecked,
        checkedAt: !item.isChecked ? DateTime.now() : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final task = widget.task;

    return Scaffold(
      backgroundColor: cc.background,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          TaskDetailsHeader(
            task: task.copyWith(status: _status),
            onBackButtonPressed: _status == TaskStatus.inProgress
                ? _onComplete
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
                    items: _checklist,
                    taskStatus: _status,
                    onToggle: _onChecklistToggle,
                  ),

                  verticalSpacing(24),

                  if (task.notes != null && task.notes!.isNotEmpty)
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
                onComplete: _onComplete,
              ),
            ),
    );
  }
}
