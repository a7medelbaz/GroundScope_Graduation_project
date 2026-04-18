import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/service/secure_storage.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/task_pause_model.dart';
import 'package:ground_scope/core/shared/data/repo/task_repo.dart';
import 'package:ground_scope/core/utils/app_constants.dart';
import 'package:ground_scope/modules/worker/features/task_details/data/repo/task_details_repo.dart';

part 'task_details_state.dart';

class TaskDetailsCubit extends Cubit<TaskDetailsState> {
  TaskDetailsCubit({required this.taskDetailsRepo, required this.taskRepo})
    : super(const TaskDetailsState());

  final TaskDetailsRepo taskDetailsRepo;
  final TaskRepo taskRepo;

  Future<UserModel?> _getUser() async {
    final jsonString = await getIt<SecureStorage>().read(
      key: AppConstants.userDataKey,
    );

    if (jsonString == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }

  Future<void> initTask({required TaskModel task}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final checklist = await taskRepo.getTaskCheckList(taskId: task.id);
      final pauses = await taskRepo.getTaskPauseHistory(taskId: task.id);

      emit(
        state.copyWith(
          checklist: checklist,
          pauses: pauses,
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
    final updated = old.map((e) {
      if (e.id == itemId) return e.copyWith(isChecked: isChecked);
      return e;
    }).toList();
    emit(state.copyWith(checklist: updated));
    try {
      final user = await _getUser();
      if (user == null) throw AppError.unauthorized('Login required');
      await taskDetailsRepo.updateChecklistItem(
        itemId: itemId,
        isChecked: isChecked,
        userId: user.id,
      );
    } catch (e) {
      emit(state.copyWith(checklist: old));
      emit(state.copyWith(error: ErrorHandler.handle(e)));
    }
  }

  Future<void> startTask(String taskId) async {
    await updateTaskStatus(taskId: taskId, newStatus: TaskStatus.inProgress);
  }

  Future<void> pauseTask({
    required String taskId,
    required String reason,
  }) async {
    final user = await _getUser();
    if (user == null) return;

    final oldStatus = state.status;

    // Optimistic update — use a temp id for now
    final tempPause = TaskPauseModel(
      id: '', // will be replaced after DB insert
      taskId: taskId,
      pausedAt: DateTime.now(),
      reason: reason,
    );

    emit(
      state.copyWith(
        status: TaskStatus.paused,
        pauses: [...state.pauses, tempPause],
      ),
    );

    try {
      // pauseTask inserts the row — we need the real id back
      // so we fetch the latest pause for this task after insert
      await taskDetailsRepo.pauseTask(
        taskId: taskId,
        reason: reason,
        userId: user.id,
      );

      // Fetch the real pause row to get its DB-generated id
      final freshPauses = await taskRepo.getTaskPauseHistory(taskId: taskId);
      print('🟡 freshPauses count: ${freshPauses.length}');
      print('🟡 freshPauses: $freshPauses');
      // Replace the temp pause with the real one from DB
      emit(state.copyWith(pauses: freshPauses));
    } catch (e) {
      // Roll back
      emit(
        state.copyWith(
          status: oldStatus,
          pauses: state.pauses.where((p) => p.id.isNotEmpty).toList(),
        ),
      );
      emit(state.copyWith(error: ErrorHandler.handle(e)));
    }
  }

  Future<void> resumeTask(String taskId) async {
    // Find the currently active pause (the one with no resumedAt)
    final activePause = state.pauses
        .where((p) => p.resumedAt == null && p.id.isNotEmpty)
        .lastOrNull; // lastOrNull in case of multiple — pick most recent

    if (activePause == null) {
      // No active pause found — just update status
      await updateTaskStatus(taskId: taskId, newStatus: TaskStatus.inProgress);
      return;
    }

    final oldStatus = state.status;
    final now = DateTime.now();

    // Optimistic: mark the active pause as resumed locally
    final updatedPauses = state.pauses.map((p) {
      if (p.id == activePause.id) return p.copyWith(resumedAt: now);
      return p;
    }).toList();

    emit(state.copyWith(status: TaskStatus.inProgress, pauses: updatedPauses));

    try {
      // Write resumed_at to task_pauses AND update tasks.status
      await taskDetailsRepo.resumePause(
        pauseId: activePause.id,
        taskId: taskId,
      );
    } catch (e) {
      // Roll back
      emit(state.copyWith(status: oldStatus, pauses: state.pauses));
      emit(state.copyWith(error: ErrorHandler.handle(e)));
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
      emit(state.copyWith(status: oldStatus));
      emit(state.copyWith(error: ErrorHandler.handle(e)));
    }
  }
}
