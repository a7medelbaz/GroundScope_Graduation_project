import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import '../../data/repo/supervisor_task_repo.dart';

part 'supervisor_tasks_state.dart';

class SupervisorTasksCubit extends Cubit<SupervisorTasksState> {
  SupervisorTasksCubit({required SupervisorTaskRepo repo})
      : _repo = repo,
        super(const SupervisorTasksState());

  final SupervisorTaskRepo _repo;

  Future<void> loadTasks(String serviceTypeId) async {
    emit(state.copyWith(status: SupervisorTasksStatus.loading));
    try {
      final tasks = await _repo.getTasks(serviceTypeId);
      final filtered = _applyFilters(tasks, state.activeFilter, state.searchQuery);
      emit(state.copyWith(
        status: SupervisorTasksStatus.loaded,
        allTasks: tasks,
        filteredTasks: filtered,
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: SupervisorTasksStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('SupervisorTasksCubit.loadTasks error: $e\n$st');
      emit(state.copyWith(
          status: SupervisorTasksStatus.failure, error: AppError.unknown()));
    }
  }

  Future<void> refresh(String serviceTypeId) => loadTasks(serviceTypeId);

  void setFilter(String filter) {
    final filtered = _applyFilters(state.allTasks, filter, state.searchQuery);
    emit(state.copyWith(activeFilter: filter, filteredTasks: filtered));
  }

  void setSearch(String query) {
    final filtered = _applyFilters(state.allTasks, state.activeFilter, query);
    emit(state.copyWith(searchQuery: query, filteredTasks: filtered));
  }

  List<TaskModel> _applyFilters(
    List<TaskModel> all,
    String filter,
    String query,
  ) {
    return all.where((t) {
      final matchesFilter = filter == 'all' || t.status?.value == filter;
      final q = query.toLowerCase();
      final matchesSearch = q.isEmpty ||
          (t.flight?.flightNumber.toLowerCase().contains(q) ?? false) ||
          (t.unit?.name.toLowerCase().contains(q) ?? false);
      return matchesFilter && matchesSearch;
    }).toList();
  }
}
