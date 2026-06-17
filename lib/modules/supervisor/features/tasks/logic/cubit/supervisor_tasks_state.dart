part of 'supervisor_tasks_cubit.dart';

sealed class SupervisorTasksState extends Equatable {
  const SupervisorTasksState();

  @override
  List<Object?> get props => [];
}

final class SupervisorTasksInitial extends SupervisorTasksState {
  const SupervisorTasksInitial();
}