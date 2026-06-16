class DashboardStatsModel {
  const DashboardStatsModel({
    required this.activeUnitsCount,
    required this.completedTasksCount,
    required this.delayedTasksCount,
    required this.reportsTodayCount,
  });

  final int activeUnitsCount;
  final int completedTasksCount;
  final int delayedTasksCount;
  final int reportsTodayCount;
}
