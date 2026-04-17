import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';

enum TaskStatus {
  pending('pending'),
  assigned('assigned'),
  inProgress('in_progress'),
  paused('paused'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const TaskStatus(this.value);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskStatus.pending,
    );
  }

  String get label => switch (this) {
    TaskStatus.pending => 'Pending',
    TaskStatus.assigned => 'Assigned',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.paused => 'Paused',
    TaskStatus.completed => 'Completed',
    TaskStatus.cancelled => 'Cancelled',
  };
}

enum TaskPriority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const TaskPriority(this.value);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskPriority.medium,
    );
  }

  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
    TaskPriority.critical => 'Critical',
  };
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.flightId,
    required this.serviceTypeId,
    this.unitId,
    this.assignedBy,
    this.createdBy,
    required this.status,
    required this.priority,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    this.notes,
    required this.createdAt,
    required this.updatedAt,

    // relations
    this.flight,
    this.serviceType,
  });

  final String id;
  final String flightId;
  final String serviceTypeId;
  final String? unitId;
  final String? assignedBy;
  final String? createdBy;

  final TaskStatus status;
  final TaskPriority priority;

  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  final FlightModel? flight;
  final ServiceTypeModel? serviceType;

  // ===== UI SAFE GETTERS =====
  String? get serviceTypeName => serviceType?.name;
  String? get serviceTypeIcon => serviceType?.icon;

  String? get flightNumber => flight?.flightNumber;
  String? get standCode => flight?.standId;

  int get durationMinutes => scheduledEnd.difference(scheduledStart).inMinutes;

  double get progress {
    return switch (status) {
      TaskStatus.pending => 0,
      TaskStatus.assigned => 0,
      TaskStatus.inProgress => 0.5,
      TaskStatus.paused => 0.5,
      TaskStatus.completed => 1,
      TaskStatus.cancelled => 0,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      flightId: map['flight_id'],
      serviceTypeId: map['service_type_id'],
      unitId: map['unit_id'],
      assignedBy: map['assigned_by'],
      createdBy: map['created_by'],
      status: TaskStatus.fromString(map['status']),
      priority: TaskPriority.fromString(map['priority']),
      scheduledStart: DateTime.parse(map['scheduled_start']),
      scheduledEnd: DateTime.parse(map['scheduled_end']),
      actualStart: map['actual_start'] != null
          ? DateTime.parse(map['actual_start'])
          : null,
      actualEnd: map['actual_end'] != null
          ? DateTime.parse(map['actual_end'])
          : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),

      flight: map['flights'] != null
          ? FlightModel.fromMap(map['flights'])
          : null,

      serviceType: map['service_types'] != null
          ? ServiceTypeModel.fromMap(map['service_types'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flight_id': flightId,
      'service_type_id': serviceTypeId,
      'unit_id': unitId,
      'assigned_by': assignedBy,
      'created_by': createdBy,
      'status': status.name,
      'priority': priority.name,
      'scheduled_start': scheduledStart.toIso8601String(),
      'scheduled_end': scheduledEnd.toIso8601String(),
      'actual_start': actualStart?.toIso8601String(),
      'actual_end': actualEnd?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
