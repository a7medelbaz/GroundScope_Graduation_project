import 'package:equatable/equatable.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';

enum ServiceRequestStatus {
  pending,
  assigned,
  inProgress,
  completed,
  cancelled;

  static ServiceRequestStatus fromString(String value) => switch (value) {
    'pending'     => ServiceRequestStatus.pending,
    'assigned'    => ServiceRequestStatus.assigned,
    'in_progress' => ServiceRequestStatus.inProgress,
    'completed'   => ServiceRequestStatus.completed,
    'cancelled'   => ServiceRequestStatus.cancelled,
    _             => ServiceRequestStatus.pending,
  };

  String get label => switch (this) {
    ServiceRequestStatus.pending    => 'Pending',
    ServiceRequestStatus.assigned   => 'Assigned',
    ServiceRequestStatus.inProgress => 'In Progress',
    ServiceRequestStatus.completed  => 'Completed',
    ServiceRequestStatus.cancelled  => 'Cancelled',
  };
}

class ServiceRequestModel extends Equatable {
  const ServiceRequestModel({
    required this.id,
    required this.flightId,
    required this.serviceTypeId,
    required this.requestedBy,
    this.assignedSupervisorId,
    required this.status,
    this.notes,
    required this.createdAt,
    this.flight,
    this.serviceTypeName,
  });

  final String id;
  final String flightId;
  final String serviceTypeId;
  final String requestedBy;
  final String? assignedSupervisorId;
  final ServiceRequestStatus status;
  final String? notes;
  final DateTime createdAt;
  final FlightModel? flight;
  final String? serviceTypeName;

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    final flightData      = json['flights']       as Map<String, dynamic>?;
    final serviceTypeData = json['service_types'] as Map<String, dynamic>?;

    return ServiceRequestModel(
      id:                   json['id']?.toString() ?? '',
      flightId:             json['flight_id']?.toString() ?? '',
      serviceTypeId:        json['service_type_id']?.toString() ?? '',
      requestedBy:          json['requested_by']?.toString() ?? '',
      assignedSupervisorId: json['assigned_supervisor_id']?.toString(),
      status:               ServiceRequestStatus.fromString(
                              json['status']?.toString() ?? 'pending'),
      notes:                json['notes']?.toString(),
      createdAt:            json['created_at'] != null
                              ? DateTime.parse(json['created_at'].toString())
                              : DateTime.now(),
      flight:               flightData != null
                              ? FlightModel.fromMap(flightData)
                              : null,
      serviceTypeName:      serviceTypeData?['name']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id, flightId, serviceTypeId, requestedBy,
    assignedSupervisorId, status, notes, createdAt,
    flight, serviceTypeName,
  ];
}
