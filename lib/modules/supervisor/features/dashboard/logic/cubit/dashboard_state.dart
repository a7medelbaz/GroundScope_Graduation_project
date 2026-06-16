part of 'dashboard_cubit.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded({required this.stats});

  final DashboardStatsModel stats;

  int get activeUnitsCount => stats.activeUnitsCount;
  int get completedTasksCount => stats.completedTasksCount;
  int get delayedTasksCount => stats.delayedTasksCount;
  int get reportsTodayCount => stats.reportsTodayCount;

  @override
  List<Object?> get props => [stats];
}

final class DashboardFailure extends DashboardState {
  const DashboardFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}
