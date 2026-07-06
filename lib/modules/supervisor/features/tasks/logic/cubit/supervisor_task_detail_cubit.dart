import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import '../../data/repo/supervisor_task_repo.dart';

part 'supervisor_task_detail_state.dart';

class SupervisorTaskDetailCubit extends Cubit<SupervisorTaskDetailState> {
  SupervisorTaskDetailCubit({required SupervisorTaskRepo repo})
      : _repo = repo,
        super(const SupervisorTaskDetailState());

  final SupervisorTaskRepo _repo;

  Future<void> loadTask(String taskId) async {
    emit(state.copyWith(status: SupervisorTaskDetailStatus.loading));
    try {
      final (task, checklist) = await _repo.getTaskById(taskId);
      if (isClosed) return;
      emit(state.copyWith(
        status: SupervisorTaskDetailStatus.loaded,
        task: task,
        checklistItems: checklist,
      ));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: SupervisorTaskDetailStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('SupervisorTaskDetailCubit.loadTask error: $e\n$st');
      if (isClosed) return;
      emit(state.copyWith(
        status: SupervisorTaskDetailStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    emit(state.copyWith(status: SupervisorTaskDetailStatus.updating));
    try {
      await _repo.updateTaskStatus(taskId, newStatus);
      if (isClosed) return;
      final updatedTask = state.task?.copyWith(
        status: TaskStatus.fromString(newStatus),
      );
      emit(state.copyWith(
        status: SupervisorTaskDetailStatus.updated,
        task: updatedTask,
      ));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: SupervisorTaskDetailStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('SupervisorTaskDetailCubit.updateTaskStatus error: $e\n$st');
      if (isClosed) return;
      emit(state.copyWith(
        status: SupervisorTaskDetailStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }
}
