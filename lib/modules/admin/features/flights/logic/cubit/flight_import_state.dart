part of 'flight_import_cubit.dart';

enum FlightImportStatus {
  initial,
  fetching,
  preview,
  importing,
  success,
  failure,
}

class FlightImportState extends Equatable {
  const FlightImportState({
    this.status = FlightImportStatus.initial,
    this.preview = const [],
    this.selectedIds = const {},
    this.importedCount = 0,
    this.error,
  });

  final FlightImportStatus status;
  final List<FlightModel> preview; // fetched from API, not yet saved
  final Set<String> selectedIds; // externalIds selected for import
  final int importedCount;
  final AppError? error;

  bool get allSelected =>
      preview.isNotEmpty && selectedIds.length == preview.length;

  FlightImportState copyWith({
    FlightImportStatus? status,
    List<FlightModel>? preview,
    Set<String>? selectedIds,
    int? importedCount,
    AppError? error,
  }) {
    return FlightImportState(
      status: status ?? this.status,
      preview: preview ?? this.preview,
      selectedIds: selectedIds ?? this.selectedIds,
      importedCount: importedCount ?? this.importedCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, preview, selectedIds, importedCount, error];
}
