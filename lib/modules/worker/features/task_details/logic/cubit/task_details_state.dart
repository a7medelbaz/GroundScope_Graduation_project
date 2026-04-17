part of 'task_details_cubit.dart';

class TaskDetailsState extends Equatable {
  final List<TaskCheckListModel> checklist;
  final bool isLoading;
  final AppError? error;

  const TaskDetailsState({
    this.checklist = const [],
    this.isLoading = false,
    this.error,
  });

  TaskDetailsState copyWith({
    List<TaskCheckListModel>? checklist,
    bool? isLoading,
    AppError? error,
  }) {
    return TaskDetailsState(
      checklist: checklist ?? this.checklist,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [checklist, isLoading, error];
}
