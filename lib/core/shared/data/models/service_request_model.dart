class AdminServiceRequestModel {
  final String id;
  final String flightId;
  final String serviceTypeId;
  final String requestedBy;
  final String? assignedSupervisorId;
  final String status;
  final String? notes;
  final DateTime createdAt;

  // Joined
  final String? serviceTypeName;

  const AdminServiceRequestModel({
    required this.id,
    required this.flightId,
    required this.serviceTypeId,
    required this.requestedBy,
    this.assignedSupervisorId,
    required this.status,
    this.notes,
    required this.createdAt,
    this.serviceTypeName,
  });

  factory AdminServiceRequestModel.fromMap(Map<String, dynamic> map) {
    final stData = map['service_types'] as Map<String, dynamic>?;
    return AdminServiceRequestModel(
      id:                   map['id']?.toString() ?? '',
      flightId:             map['flight_id']?.toString() ?? '',
      serviceTypeId:        map['service_type_id']?.toString() ?? '',
      requestedBy:          map['requested_by']?.toString() ?? '',
      assignedSupervisorId: map['assigned_supervisor_id']?.toString(),
      status:               map['status']?.toString() ?? 'pending',
      notes:                map['notes']?.toString(),
      createdAt:            map['created_at'] != null
                              ? DateTime.parse(map['created_at'])
                              : DateTime.now(),
      serviceTypeName:      stData?['name']?.toString(),
    );
  }

  bool get isPending   => status == 'pending';
  bool get isAssigned  => status == 'assigned';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}
