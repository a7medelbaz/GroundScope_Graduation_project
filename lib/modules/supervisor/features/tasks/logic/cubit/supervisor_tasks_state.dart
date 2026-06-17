part of 'supervisor_tasks_cubit.dart';

enum SupervisorTasksStatus { initial, loading, loaded, failure }

final class SupervisorTasksState extends Equatable {
  const SupervisorTasksState({
    this.status = SupervisorTasksStatus.initial,
    this.allTasks = const [],
    this.filteredTasks = const [],
    this.activeFilter = 'all',
    this.searchQuery = '',
    this.error,
  });

  final SupervisorTasksStatus status;
  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final String activeFilter;
  final String searchQuery;
  final AppError? error;

  int get resultCount => filteredTasks.length;

  SupervisorTasksState copyWith({
    SupervisorTasksStatus? status,
    List<TaskModel>? allTasks,
    List<TaskModel>? filteredTasks,
    String? activeFilter,
    String? searchQuery,
    AppError? error,
  }) {
    return SupervisorTasksState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, allTasks, filteredTasks, activeFilter, searchQuery, error];
}
