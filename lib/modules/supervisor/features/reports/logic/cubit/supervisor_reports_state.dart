part of 'supervisor_reports_cubit.dart';

enum SupervisorReportsStatus { initial, loading, success, failure, deleting }

class SupervisorReportsState {
  const SupervisorReportsState({
    this.status = SupervisorReportsStatus.initial,
    this.reports = const [],
    this.deletingReportId,
    this.error,
  });

  final SupervisorReportsStatus status;
  final List<ReportModel> reports;
  final String? deletingReportId;
  final AppError? error;

  SupervisorReportsState copyWith({
    SupervisorReportsStatus? status,
    List<ReportModel>? reports,
    String? deletingReportId,
    AppError? error,
    bool clearDeletingId = false,
  }) {
    return SupervisorReportsState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      deletingReportId:
          clearDeletingId ? null : (deletingReportId ?? this.deletingReportId),
      error: error ?? this.error,
    );
  }
}
