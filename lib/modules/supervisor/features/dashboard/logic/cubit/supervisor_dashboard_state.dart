part of 'supervisor_dashboard_cubit.dart';

enum DashboardStatus { initial, loading, success, failure, sessionExpired }

class SupervisorDashboardState extends Equatable {
  const SupervisorDashboardState({
    this.status = DashboardStatus.initial,
    this.stats,
    this.taskSummary,
    this.error,
  });

  final DashboardStatus status;
  final DashboardStatsModel? stats;
  final TaskStatusSummaryModel? taskSummary;
  final AppError? error;

  bool get isLoading => status == DashboardStatus.loading;
  bool get hasData => stats != null && taskSummary != null;

  SupervisorDashboardState copyWith({
    DashboardStatus? status,
    DashboardStatsModel? stats,
    TaskStatusSummaryModel? taskSummary,
    AppError? error,
    bool clearError = false,
  }) {
    return SupervisorDashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      taskSummary: taskSummary ?? this.taskSummary,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, stats, taskSummary, error];
}
