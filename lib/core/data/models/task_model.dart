// lib/modules/worker/features/home/data/models/task_model.dart

enum TaskStatus {
  pending,
  assigned,
  inProgress,
  paused,
  completed,
  cancelled;

  static TaskStatus fromString(String value) {
    return switch (value) {
      'pending' => TaskStatus.pending,
      'assigned' => TaskStatus.assigned,
      'in_progress' => TaskStatus.inProgress,
      'paused' => TaskStatus.paused,
      'completed' => TaskStatus.completed,
      'cancelled' => TaskStatus.cancelled,
      _ => TaskStatus.pending,
    };
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
  low,
  medium,
  high,
  critical;

  static TaskPriority fromString(String value) {
    return switch (value) {
      'low' => TaskPriority.low,
      'medium' => TaskPriority.medium,
      'high' => TaskPriority.high,
      'critical' => TaskPriority.critical,
      _ => TaskPriority.medium,
    };
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
    // Joined fields (from related tables — populated when fetched with joins)
    this.serviceTypeName,
    this.serviceTypeIcon,
    this.flightNumber,
    this.standCode,
    this.checklistTotal = 0,
    this.checklistDone = 0,
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

  // Joined / derived fields
  final String? serviceTypeName;
  final String? serviceTypeIcon;
  final String? flightNumber;
  final String? standCode;
  final int checklistTotal;
  final int checklistDone;

  /// Progress from 0.0 to 1.0 based on checklist completion.
  /// Falls back to status-based estimate when no checklist data.
  double get progress {
    if (checklistTotal > 0) return checklistDone / checklistTotal;
    return switch (status) {
      TaskStatus.pending => 0.0,
      TaskStatus.assigned => 0.0,
      TaskStatus.inProgress => 0.5,
      TaskStatus.paused => 0.5,
      TaskStatus.completed => 1.0,
      TaskStatus.cancelled => 0.0,
    };
  }

  /// Formatted scheduled window e.g. "07:30 - 08:15"
  String get scheduledTimeRange {
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${fmt(scheduledStart)} – ${fmt(scheduledEnd)}';
  }

  /// Duration in minutes
  int get durationMinutes => scheduledEnd.difference(scheduledStart).inMinutes;

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      flightId: map['flight_id'] as String,
      serviceTypeId: map['service_type_id'] as String,
      unitId: map['unit_id'] as String?,
      assignedBy: map['assigned_by'] as String?,
      createdBy: map['created_by'] as String?,
      status: TaskStatus.fromString(map['status'] as String),
      priority: TaskPriority.fromString(map['priority'] as String),
      scheduledStart: DateTime.parse(map['scheduled_start'] as String),
      scheduledEnd: DateTime.parse(map['scheduled_end'] as String),
      actualStart: map['actual_start'] != null
          ? DateTime.parse(map['actual_start'] as String)
          : null,
      actualEnd: map['actual_end'] != null
          ? DateTime.parse(map['actual_end'] as String)
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      serviceTypeName: map['service_type_name'] as String?,
      serviceTypeIcon: map['service_type_icon'] as String?,
      flightNumber: map['flight_number'] as String?,
      standCode: map['stand_code'] as String?,
      checklistTotal: (map['checklist_total'] as int?) ?? 0,
      checklistDone: (map['checklist_done'] as int?) ?? 0,
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
