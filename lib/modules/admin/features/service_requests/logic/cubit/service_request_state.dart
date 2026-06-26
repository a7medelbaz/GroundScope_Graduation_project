part of 'service_request_cubit.dart';

enum SrLoadStatus { initial, loading, success, submitting, failure }

class ServiceRequestState extends Equatable {
  const ServiceRequestState({
    this.status = SrLoadStatus.initial,
    this.flight,
    this.existingRequests = const [],
    this.allServiceTypes = const [],
    this.selectedServiceTypeIds = const {},
    this.notes = '',
    this.error,
  });

  final SrLoadStatus status;
  final FlightModel? flight;
  final List<AdminServiceRequestModel> existingRequests;
  final List<ServiceTypeModel> allServiceTypes;
  final Set<String> selectedServiceTypeIds;
  final String notes;
  final AppError? error;

  /// Service types that don't have an active (non-cancelled) request yet.
  List<ServiceTypeModel> get availableServiceTypes {
    final requestedIds = existingRequests
        .where((r) => !r.isCancelled)
        .map((r) => r.serviceTypeId)
        .toSet();
    return allServiceTypes
        .where((st) => !requestedIds.contains(st.id))
        .toList();
  }

  ServiceRequestState copyWith({
    SrLoadStatus? status,
    FlightModel? flight,
    List<AdminServiceRequestModel>? existingRequests,
    List<ServiceTypeModel>? allServiceTypes,
    Set<String>? selectedServiceTypeIds,
    String? notes,
    AppError? error,
  }) {
    return ServiceRequestState(
      status:                 status ?? this.status,
      flight:                 flight ?? this.flight,
      existingRequests:       existingRequests ?? this.existingRequests,
      allServiceTypes:        allServiceTypes ?? this.allServiceTypes,
      selectedServiceTypeIds: selectedServiceTypeIds ?? this.selectedServiceTypeIds,
      notes:                  notes ?? this.notes,
      error:                  error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status, flight, existingRequests, allServiceTypes,
    selectedServiceTypeIds, notes, error,
  ];
}
