part of 'admin_dashboard_cubit.dart';

enum AdminDashboardStatus { initial, loading, success, failure }

class AdminDashboardState extends Equatable {
  const AdminDashboardState({
    this.status = AdminDashboardStatus.initial,
    this.adminName,
    this.activeFlightsCount = 0,
    this.pendingTasksCount = 0,
    this.openReportsCount = 0,
    this.activeUnitsCount = 0,
    this.flightsNeedingAttentionCount = 0,
    this.error,
  });

  final AdminDashboardStatus status;
  final String? adminName;
  final int activeFlightsCount;
  final int pendingTasksCount;
  final int openReportsCount;
  final int activeUnitsCount;
  final int flightsNeedingAttentionCount;
  final AppError? error;

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    String? adminName,
    int? activeFlightsCount,
    int? pendingTasksCount,
    int? openReportsCount,
    int? activeUnitsCount,
    int? flightsNeedingAttentionCount,
    AppError? error,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      adminName: adminName ?? this.adminName,
      activeFlightsCount: activeFlightsCount ?? this.activeFlightsCount,
      pendingTasksCount: pendingTasksCount ?? this.pendingTasksCount,
      openReportsCount: openReportsCount ?? this.openReportsCount,
      activeUnitsCount: activeUnitsCount ?? this.activeUnitsCount,
      flightsNeedingAttentionCount:
          flightsNeedingAttentionCount ?? this.flightsNeedingAttentionCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        adminName,
        activeFlightsCount,
        pendingTasksCount,
        openReportsCount,
        activeUnitsCount,
        flightsNeedingAttentionCount,
        error,
      ];
}
