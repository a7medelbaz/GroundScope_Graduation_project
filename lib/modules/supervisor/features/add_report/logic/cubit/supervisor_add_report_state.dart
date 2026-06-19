part of 'supervisor_add_report_cubit.dart';

enum SupervisorAddReportStatus { idle, loading, submitted, failure }

class SupervisorAddReportState extends Equatable {
  const SupervisorAddReportState({
    this.status = SupervisorAddReportStatus.idle,
    this.reportedTo = 'admin',
    this.type = ReportType.issue,
    this.severity = ReportSeverity.medium,
    this.imageFile,
    this.error,
  });

  final SupervisorAddReportStatus status;
  final String reportedTo;
  final ReportType type;
  final ReportSeverity severity;
  final File? imageFile;
  final AppError? error;

  bool get isSubmitting => status == SupervisorAddReportStatus.loading;
  bool get hasImage => imageFile != null;

  SupervisorAddReportState copyWith({
    SupervisorAddReportStatus? status,
    String? reportedTo,
    ReportType? type,
    ReportSeverity? severity,
    File? imageFile,
    bool clearImage = false,
    AppError? error,
    bool clearError = false,
  }) {
    return SupervisorAddReportState(
      status: status ?? this.status,
      reportedTo: reportedTo ?? this.reportedTo,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      imageFile: clearImage ? null : (imageFile ?? this.imageFile),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [status, reportedTo, type, severity, imageFile, error];
}
