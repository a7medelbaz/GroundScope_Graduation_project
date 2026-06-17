part of 'unit_detail_cubit.dart';

enum UnitDetailStatus { initial, loading, success, failure }

class UnitDetailState extends Equatable {
  const UnitDetailState({
    this.status = UnitDetailStatus.initial,
    this.unit,
    this.tasks = const [],
    this.members = const [],
    this.error,
  });

  final UnitDetailStatus status;
  final UnitModel? unit;
  final List<TaskModel> tasks;
  final List<UnitMemberModel> members;
  final AppError? error;

  List<TaskModel> get activeTasks => tasks.where((t) {
        final s = t.status?.value ?? '';
        return !['completed', 'cancelled'].contains(s);
      }).toList();

  List<TaskModel> get recentTasks => tasks.where((t) {
        final s = t.status?.value ?? '';
        return ['completed', 'cancelled'].contains(s);
      }).toList();

  UnitDetailState copyWith({
    UnitDetailStatus? status,
    UnitModel? unit,
    List<TaskModel>? tasks,
    List<UnitMemberModel>? members,
    AppError? error,
  }) {
    return UnitDetailState(
      status: status ?? this.status,
      unit: unit ?? this.unit,
      tasks: tasks ?? this.tasks,
      members: members ?? this.members,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, unit, tasks, members, error];
}
