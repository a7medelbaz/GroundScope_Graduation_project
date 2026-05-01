part of 'reports_cubit.dart';

enum ReportsStatus { initial, loading, loaded, failure }

class ReportsState extends Equatable {
  const ReportsState({
    this.status = ReportsStatus.initial,
    this.reports = const [],
    this.error,
    this.selectedFilter,
  });

  final ReportsStatus status;
  final List<ReportModel> reports;
  final AppError? error;
  final ReportStatus? selectedFilter;

  List<ReportModel> get filteredReports => selectedFilter == null
      ? reports
      : reports.where((r) => r.status == selectedFilter).toList();

  ReportsState copyWith({
    ReportsStatus? status,
    List<ReportModel>? reports,
    AppError? error,
    bool clearError = false,
    ReportStatus? selectedFilter,
    bool clearFilter = false,
  }) {
    return ReportsState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      error: clearError ? null : (error ?? this.error),
      selectedFilter:
          clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    );
  }

  @override
  List<Object?> get props => [status, reports, error, selectedFilter];
}
