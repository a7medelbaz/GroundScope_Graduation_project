import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/task_pause_model.dart';
import 'package:ground_scope/core/shared/data/repo/task_repo.dart';
import '../../data/repo/task_details_repo.dart';

part 'task_details_state.dart';

class TaskDetailsCubit extends Cubit<TaskDetailsState> {
  TaskDetailsCubit({
    required this.taskDetailsRepo,
    required this.taskRepo,
    required this.userService,
  }) : super(const TaskDetailsState());

  final TaskDetailsRepo taskDetailsRepo;
  final TaskRepo taskRepo;
  final UserService userService;

  Future<void> initTask({required TaskModel task}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        taskRepo.getTaskCheckList(taskId: task.id),
        taskRepo.getTaskPauseHistory(taskId: task.id),
      ]);
      emit(
        state.copyWith(
          checklist: results[0] as List<TaskCheckListModel>,
          pauses: results[1] as List<TaskPauseModel>,
          status: task.status,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e is AppError ? e : ErrorHandler.handle(e),
        ),
      );
    }
  }

  Future<void> updateChecklistItem({
    required String itemId,
    required bool isChecked,
  }) async {
    final old = state.checklist;
    emit(
      state.copyWith(
        checklist: old
            .map((e) => e.id == itemId ? e.copyWith(isChecked: isChecked) : e)
            .toList(),
      ),
    );
    try {
      final user = await userService.getUser();
      if (user == null) throw AppError.unauthorized('Login required');
      await taskDetailsRepo.updateChecklistItem(
        itemId: itemId,
        isChecked: isChecked,
        userId: user.id,
      );
    } catch (e) {
      emit(state.copyWith(checklist: old, error: ErrorHandler.handle(e)));
    }
  }

  Future<void> startTask(String taskId) async {
    await updateTaskStatus(taskId: taskId, newStatus: TaskStatus.inProgress);
  }

  Future<void> pauseTask({
    required String taskId,
    required String reason,
  }) async {
    final user = await userService.getUser();
    if (user == null) return;

    final oldStatus = state.status;

    emit(
      state.copyWith(
        status: TaskStatus.paused,
        pauses: [
          ...state.pauses,
          TaskPauseModel(
            id: '', // temp — replaced after fetch
            taskId: taskId,
            pausedAt: DateTime.now(),
            reason: reason,
          ),
        ],
      ),
    );

    try {
      await taskDetailsRepo.pauseTask(
        taskId: taskId,
        reason: reason,
        userId: user.id,
      );
      final freshPauses = await taskRepo.getTaskPauseHistory(taskId: taskId);
      emit(state.copyWith(pauses: freshPauses));
    } catch (e) {
      emit(
        state.copyWith(
          status: oldStatus,
          pauses: state.pauses.where((p) => p.id.isNotEmpty).toList(),
          error: ErrorHandler.handle(e),
        ),
      );
    }
  }

  Future<void> resumeTask(String taskId) async {
    final activePause = state.pauses
        .where((p) => p.resumedAt == null && p.id.isNotEmpty)
        .lastOrNull;

    if (activePause == null) {
      await updateTaskStatus(taskId: taskId, newStatus: TaskStatus.inProgress);
      return;
    }

    final oldStatus = state.status;
    final now = DateTime.now();

    emit(
      state.copyWith(
        status: TaskStatus.inProgress,
        pauses: state.pauses
            .map((p) => p.id == activePause.id ? p.copyWith(resumedAt: now) : p)
            .toList(),
      ),
    );

    try {
      await taskDetailsRepo.resumePause(
        pauseId: activePause.id,
        taskId: taskId,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: oldStatus,
          pauses: state.pauses,
          error: ErrorHandler.handle(e),
        ),
      );
    }
  }

  Future<void> completeTask(String taskId) async {
    await updateTaskStatus(taskId: taskId, newStatus: TaskStatus.completed);
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    final oldStatus = state.status;
    emit(state.copyWith(status: newStatus));
    try {
      await taskDetailsRepo.updateTaskStatus(
        taskId: taskId,
        newStatus: newStatus,
      );
    } catch (e) {
      emit(state.copyWith(status: oldStatus, error: ErrorHandler.handle(e)));
    }
  }
}
