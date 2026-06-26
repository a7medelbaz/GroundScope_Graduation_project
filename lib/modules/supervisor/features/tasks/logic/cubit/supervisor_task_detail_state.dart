part of 'supervisor_task_detail_cubit.dart';

enum SupervisorTaskDetailStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  failure,
}

class SupervisorTaskDetailState extends Equatable {
  const SupervisorTaskDetailState({
    this.status = SupervisorTaskDetailStatus.initial,
    this.task,
    this.checklistItems = const [],
    this.error,
  });

  final SupervisorTaskDetailStatus status;
  final TaskModel? task;
  final List<TaskCheckListModel> checklistItems;
  final AppError? error;

  SupervisorTaskDetailState copyWith({
    SupervisorTaskDetailStatus? status,
    TaskModel? task,
    List<TaskCheckListModel>? checklistItems,
    AppError? error,
  }) {
    return SupervisorTaskDetailState(
      status: status ?? this.status,
      task: task ?? this.task,
      checklistItems: checklistItems ?? this.checklistItems,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, task, checklistItems, error];
}
