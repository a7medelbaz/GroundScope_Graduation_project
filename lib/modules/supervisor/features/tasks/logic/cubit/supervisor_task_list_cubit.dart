import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/repo/task_repo.dart';

part 'supervisor_task_list_state.dart';

class SupervisorTaskListCubit extends Cubit<SupervisorTaskListState> {
  SupervisorTaskListCubit({required this.taskRepo})
      : super(SupervisorTaskListInitial());

  final TaskRepo taskRepo;

  Future<void> loadTasks(TaskStatus status) async {
    emit(SupervisorTaskListLoading());
    try {
      final tasks = await taskRepo.fetchTasksByStatus(status);
      emit(SupervisorTaskListLoaded(allTasks: tasks, filteredTasks: tasks));
    } on AppError catch (e) {
      emit(SupervisorTaskListFailure(error: e));
    } catch (_) {
      emit(SupervisorTaskListFailure(error: AppError.unknown()));
    }
  }

  void search(String query) {
    final current = state;
    if (current is! SupervisorTaskListLoaded) return;

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? current.allTasks
        : current.allTasks.where((t) {
            return (t.flightNumber?.toLowerCase().contains(q) ?? false) ||
                (t.serviceTypeName?.toLowerCase().contains(q) ?? false) ||
                (t.standCode?.toLowerCase().contains(q) ?? false);
          }).toList();

    emit(current.copyWith(filteredTasks: filtered, searchQuery: query));
  }
}
