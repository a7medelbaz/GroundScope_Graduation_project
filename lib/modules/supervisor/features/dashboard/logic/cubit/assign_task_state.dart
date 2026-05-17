part of 'assign_task_cubit.dart';

enum AssignTaskStatus {
  initial,
  loadingFormData,
  formReady,
  submitting,
  success,
  failure,
}

class AssignTaskState extends Equatable {
  const AssignTaskState({
    this.status = AssignTaskStatus.initial,
    this.flights = const [],
    this.allUnits = const [],
    this.serviceTypes = const [],
    this.filteredUnits = const [],
    this.selectedFlight,
    this.selectedServiceType,
    this.selectedUnit,
    this.priority = TaskPriority.medium,
    this.scheduledStart,
    this.scheduledEnd,
    this.notes,
    this.error,
  });

  final AssignTaskStatus status;
  final List<FlightModel> flights;
  final List<UnitModel> allUnits;
  final List<ServiceTypeModel> serviceTypes;
  final List<UnitModel> filteredUnits;
  final FlightModel? selectedFlight;
  final ServiceTypeModel? selectedServiceType;
  final UnitModel? selectedUnit;
  final TaskPriority priority;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String? notes;
  final AppError? error;

  bool get isFormValid =>
      selectedFlight != null &&
      selectedServiceType != null &&
      selectedUnit != null &&
      scheduledStart != null &&
      scheduledEnd != null &&
      scheduledEnd!.isAfter(scheduledStart!);

  AssignTaskState copyWith({
    AssignTaskStatus? status,
    List<FlightModel>? flights,
    List<UnitModel>? allUnits,
    List<ServiceTypeModel>? serviceTypes,
    List<UnitModel>? filteredUnits,
    FlightModel? selectedFlight,
    ServiceTypeModel? selectedServiceType,
    UnitModel? selectedUnit,
    TaskPriority? priority,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    String? notes,
    AppError? error,
    bool clearUnit = false,
  }) {
    return AssignTaskState(
      status: status ?? this.status,
      flights: flights ?? this.flights,
      allUnits: allUnits ?? this.allUnits,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      filteredUnits: filteredUnits ?? this.filteredUnits,
      selectedFlight: selectedFlight ?? this.selectedFlight,
      selectedServiceType: selectedServiceType ?? this.selectedServiceType,
      selectedUnit: clearUnit ? null : (selectedUnit ?? this.selectedUnit),
      priority: priority ?? this.priority,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      notes: notes ?? this.notes,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    flights,
    allUnits,
    serviceTypes,
    filteredUnits,
    selectedFlight,
    selectedServiceType,
    selectedUnit,
    priority,
    scheduledStart,
    scheduledEnd,
    notes,
    error,
  ];
}
