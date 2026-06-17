import 'package:equatable/equatable.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';

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
  });

  final String id;
  final String flightId;
  final String serviceTypeId;
  final String requestedBy;
  final String? assignedSupervisorId;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final FlightModel? flight;

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id']?.toString() ?? '',
      flightId: json['flight_id']?.toString() ?? '',
      serviceTypeId: json['service_type_id']?.toString() ?? '',
      requestedBy: json['requested_by']?.toString() ?? '',
      assignedSupervisorId: json['assigned_supervisor_id']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      flight: json['flights'] is Map<String, dynamic>
          ? FlightModel.fromMap(json['flights'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        flightId,
        serviceTypeId,
        requestedBy,
        assignedSupervisorId,
        status,
        notes,
        createdAt,
        flight,
      ];
}