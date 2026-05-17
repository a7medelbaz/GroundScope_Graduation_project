import 'package:equatable/equatable.dart';

class DashboardStatsModel extends Equatable {
  const DashboardStatsModel({
    this.activeUnits,
    this.completedTasksToday,
    this.delayedTasks,
    this.reportsToday,
  });

  final int? activeUnits;
  final int? completedTasksToday;
  final int? delayedTasks;
  final int? reportsToday;

  @override
  List<Object?> get props => [
    activeUnits,
    completedTasksToday,
    delayedTasks,
    reportsToday,
  ];
}

class TaskStatusSummaryModel extends Equatable {
  const TaskStatusSummaryModel({
    required this.total,
    required this.done,
    required this.inProgress,
    required this.delayed,
  });

  final int total;
  final int done;
  final int inProgress;
  final int delayed;

  double get donePct => total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
  double get inProgressPct =>
      total > 0 ? (inProgress / total).clamp(0.0, 1.0) : 0.0;
  double get delayedPct =>
      total > 0 ? (delayed / total).clamp(0.0, 1.0) : 0.0;
  bool get isEmpty => total == 0;

  @override
  List<Object?> get props => [total, done, inProgress, delayed];
}
