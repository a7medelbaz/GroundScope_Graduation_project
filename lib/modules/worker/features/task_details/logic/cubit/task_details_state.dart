part of 'task_details_cubit.dart';

class TaskDetailsState extends Equatable {
  final List<TaskCheckListModel> checklist;
  final List<TaskPauseModel> pauses;
  final bool isLoading;
  final AppError? error;
  final TaskStatus? status;

  const TaskDetailsState({
    this.checklist = const [],
    this.pauses = const [],
    this.isLoading = false,
    this.error,
    this.status = TaskStatus.assigned,
  });

  TaskDetailsState copyWith({
    List<TaskCheckListModel>? checklist,
    List<TaskPauseModel>? pauses,
    bool? isLoading,
    AppError? error,
    TaskStatus? status,
  }) {
    return TaskDetailsState(
      checklist: checklist ?? this.checklist,
      pauses: pauses ?? this.pauses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [checklist, pauses, isLoading, error, status];
}
