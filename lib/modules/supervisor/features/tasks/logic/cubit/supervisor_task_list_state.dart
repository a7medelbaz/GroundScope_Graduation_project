part of 'supervisor_task_list_cubit.dart';

sealed class SupervisorTaskListState extends Equatable {
  const SupervisorTaskListState();

  @override
  List<Object?> get props => [];
}

final class SupervisorTaskListInitial extends SupervisorTaskListState {}

final class SupervisorTaskListLoading extends SupervisorTaskListState {}

final class SupervisorTaskListLoaded extends SupervisorTaskListState {
  const SupervisorTaskListLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.searchQuery = '',
  });

  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final String searchQuery;

  SupervisorTaskListLoaded copyWith({
    List<TaskModel>? allTasks,
    List<TaskModel>? filteredTasks,
    String? searchQuery,
  }) {
    return SupervisorTaskListLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allTasks, filteredTasks, searchQuery];
}

final class SupervisorTaskListFailure extends SupervisorTaskListState {
  const SupervisorTaskListFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}
