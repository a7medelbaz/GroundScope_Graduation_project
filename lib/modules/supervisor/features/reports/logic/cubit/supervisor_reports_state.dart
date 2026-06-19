part of 'supervisor_reports_cubit.dart';

enum SupervisorReportsStatus { initial, loading, loaded, actionLoading, failure }

// Sentinel for "clear actionReportId to null"
const _clearId = Object();

final class SupervisorReportsState extends Equatable {
  const SupervisorReportsState({
    this.status = SupervisorReportsStatus.initial,
    this.allReports = const [],
    this.filteredReports = const [],
    this.activeFilter = 'all',
    this.activeSeverityFilter = 'all',
    this.activeRoleFilter = 'all',
    this.searchQuery = '',
    this.actionReportId,
    this.error,
  });

  final SupervisorReportsStatus status;
  final List<ReportModel> allReports;
  final List<ReportModel> filteredReports;
  final String activeFilter;
  final String activeSeverityFilter;
  final String activeRoleFilter;
  final String searchQuery;
  final String? actionReportId;
  final AppError? error;

  int get resultCount => filteredReports.length;

  int get activeAdvancedFilterCount =>
      (activeSeverityFilter != 'all' ? 1 : 0) +
      (activeRoleFilter != 'all' ? 1 : 0);

  SupervisorReportsState copyWith({
    SupervisorReportsStatus? status,
    List<ReportModel>? allReports,
    List<ReportModel>? filteredReports,
    String? activeFilter,
    String? activeSeverityFilter,
    String? activeRoleFilter,
    String? searchQuery,
    Object? actionReportId = _clearId,
    AppError? error,
  }) {
    return SupervisorReportsState(
      status: status ?? this.status,
      allReports: allReports ?? this.allReports,
      filteredReports: filteredReports ?? this.filteredReports,
      activeFilter: activeFilter ?? this.activeFilter,
      activeSeverityFilter: activeSeverityFilter ?? this.activeSeverityFilter,
      activeRoleFilter: activeRoleFilter ?? this.activeRoleFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      actionReportId: identical(actionReportId, _clearId)
          ? this.actionReportId
          : actionReportId as String?,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allReports,
        filteredReports,
        activeFilter,
        activeSeverityFilter,
        activeRoleFilter,
        searchQuery,
        actionReportId,
        error,
      ];
}
