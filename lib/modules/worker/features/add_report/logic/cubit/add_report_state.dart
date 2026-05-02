part of 'add_report_cubit.dart';

enum AddReportStatus { idle, loading, success, submitted, failure }

class AddReportState extends Equatable {
  const AddReportState({
    this.tasks,
    this.status = AddReportStatus.idle,
    this.selectedTaskId,
    this.selectedFlightId,
    this.selectedTaskLabel,
    this.type = ReportType.issue,
    this.severity = ReportSeverity.medium,
    this.imageFile,
    this.error,
  });

  final AddReportStatus status;
  final List<TaskModel>? tasks;

  // Task selection
  final String? selectedTaskId;
  final String? selectedFlightId;
  final String? selectedTaskLabel;

  // Form fields
  final ReportType type;
  final ReportSeverity severity;
  final File? imageFile;

  // ✅ Single source of truth
  final AppError? error;

  bool get isSubmitting => status == AddReportStatus.loading;
  bool get hasTask => selectedTaskId != null;
  bool get hasImage => imageFile != null;

  AddReportState copyWith({
    AddReportStatus? status,
    List<TaskModel>? tasks,
    String? selectedTaskId,
    String? selectedFlightId,
    String? selectedTaskLabel,
    ReportType? type,
    ReportSeverity? severity,
    File? imageFile,
    bool clearImage = false,
    AppError? error,
    bool clearError = false,
  }) {
    return AddReportState(
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      selectedFlightId: selectedFlightId ?? this.selectedFlightId,
      selectedTaskLabel: selectedTaskLabel ?? this.selectedTaskLabel,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      imageFile: clearImage ? null : (imageFile ?? this.imageFile),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    selectedTaskId,
    selectedFlightId,
    selectedTaskLabel,
    type,
    severity,
    imageFile,
    error,
  ];
}
