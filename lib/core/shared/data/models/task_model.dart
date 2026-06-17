import 'flight_model.dart';
import 'unit_model.dart';

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

extension TaskStatusDb on TaskStatus {
  String get dbValue => switch (this) {
    TaskStatus.pending => 'pending',
    TaskStatus.assigned => 'assigned',
    TaskStatus.inProgress => 'in_progress',
    TaskStatus.paused => 'paused',
    TaskStatus.completed => 'completed',
    TaskStatus.cancelled => 'cancelled',
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
    this.serviceTypeName,
    this.serviceTypeIcon,
    // Rich objects
    this.flight,
    this.unit,
    this.checklistTotal = 0,
    this.checklistDone = 0,
  });

  final String id;
  final String flightId;
  final String serviceTypeId;
  final String? unitId;
  final String? assignedBy;
  final String? createdBy;
  final TaskStatus? status;
  final TaskPriority priority;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Joined Objects
  final String? serviceTypeName;
  final String? serviceTypeIcon;
  final FlightModel? flight;
  final UnitModel? unit;

  /// Checklist
  final int checklistTotal;
  final int checklistDone;

  // Helpers
  String? get flightNumber => flight?.flightNumber;
  String? get standCode => flight?.stand?.code;

  double get progress {
    if (checklistTotal > 0) {
      return (checklistDone / checklistTotal).clamp(0.0, 1.0);
    }
    return switch (status) {
      TaskStatus.completed => 1.0,
      TaskStatus.inProgress || TaskStatus.paused => 0.5,
      _ => 0.0,
    };
  }

  String get scheduledTimeRange {
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return '${fmt(scheduledStart)} – ${fmt(scheduledEnd)}';
  }

  int get durationMinutes => scheduledEnd.difference(scheduledStart).inMinutes;

  TaskModel copyWith({
    String? id,
    String? flightId,
    String? serviceTypeId,
    String? unitId,
    String? assignedBy,
    String? createdBy,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    DateTime? actualStart,
    DateTime? actualEnd,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serviceTypeName,
    String? serviceTypeIcon,
    FlightModel? flight,
    UnitModel? unit,
    int? checklistTotal,
    int? checklistDone,
  }) {
    return TaskModel(
      id: id ?? this.id,
      flightId: flightId ?? this.flightId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      unitId: unitId ?? this.unitId,
      assignedBy: assignedBy ?? this.assignedBy,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
      serviceTypeIcon: serviceTypeIcon ?? this.serviceTypeIcon,
      flight: flight ?? this.flight,
      unit: unit ?? this.unit,
      checklistTotal: checklistTotal ?? this.checklistTotal,
      checklistDone: checklistDone ?? this.checklistDone,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    // 1. Extract nested maps from the Supabase join
    final flightMap = map['flights'] as Map<String, dynamic>?;
    final unitMap = map['units'] as Map<String, dynamic>?;
    final serviceType = map['service_types'] as Map<String, dynamic>?;

    return TaskModel(
      id: map['id'],
      // flightId must be the String UUID from the tasks table
      flightId: map['flight_id']?.toString() ?? '',
      serviceTypeId: map['service_type_id']?.toString() ?? '',
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

      // 2. Map Service Type Data
      serviceTypeName: serviceType?['name'],
      serviceTypeIcon: serviceType?['icon'],

      // 3. Map nested Flight and Unit from joins
      flight: flightMap != null ? FlightModel.fromMap(flightMap) : null,
      unit: unitMap != null ? UnitModel.fromJson(unitMap) : null,

      checklistTotal: map['checklist_total'] ?? 0,
      checklistDone: map['checklist_done'] ?? 0,
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
      'status': status!.value,
      'priority': priority.value,
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
