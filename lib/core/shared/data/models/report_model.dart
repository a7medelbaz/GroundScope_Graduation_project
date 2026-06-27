import 'flight_model.dart';

enum ReportDirection {
  workerToSupervisor,
  supervisorToUnit,
  supervisorToAdmin,
  adminToSupervisor,
  adminBroadcast;

  static ReportDirection fromString(String value) => switch (value) {
        'worker_to_supervisor' => ReportDirection.workerToSupervisor,
        'supervisor_to_unit' => ReportDirection.supervisorToUnit,
        'supervisor_to_admin' => ReportDirection.supervisorToAdmin,
        'admin_to_supervisor' => ReportDirection.adminToSupervisor,
        'admin_broadcast' => ReportDirection.adminBroadcast,
        _ => ReportDirection.workerToSupervisor,
      };

  String get toDbString => switch (this) {
        ReportDirection.workerToSupervisor => 'worker_to_supervisor',
        ReportDirection.supervisorToUnit => 'supervisor_to_unit',
        ReportDirection.supervisorToAdmin => 'supervisor_to_admin',
        ReportDirection.adminToSupervisor => 'admin_to_supervisor',
        ReportDirection.adminBroadcast => 'admin_broadcast',
      };

  String get label => switch (this) {
        ReportDirection.workerToSupervisor => 'From Worker',
        ReportDirection.supervisorToUnit => 'Alert to Unit',
        ReportDirection.supervisorToAdmin => 'Forwarded to Admin',
        ReportDirection.adminToSupervisor => 'From Admin',
        ReportDirection.adminBroadcast => 'Broadcast',
      };
}

enum ReportType {
  issue('issue'),
  delay('delay'),
  damage('damage'),
  safety('safety'),
  other('other');

  final String value;
  const ReportType(this.value);

  static ReportType fromString(String value) {
    return ReportType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportType.other,
    );
  }

  String get label => switch (this) {
        ReportType.issue => 'Issue',
        ReportType.delay => 'Delay',
        ReportType.damage => 'Damage',
        ReportType.safety => 'Safety',
        ReportType.other => 'Other',
      };

  String get icon => switch (this) {
        ReportType.issue => '⚠️',
        ReportType.delay => '⏱️',
        ReportType.damage => '🔧',
        ReportType.safety => '🛡️',
        ReportType.other => '📋',
      };
}

enum ReportSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const ReportSeverity(this.value);

  static ReportSeverity fromString(String value) {
    return ReportSeverity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportSeverity.low,
    );
  }

  String get label => switch (this) {
        ReportSeverity.low => 'Low',
        ReportSeverity.medium => 'Medium',
        ReportSeverity.high => 'High',
        ReportSeverity.critical => 'Critical',
      };
}

enum ReportStatus {
  open('open'),
  acknowledged('acknowledged'),
  inProgress('in_progress'),
  resolved('resolved');

  final String value;
  const ReportStatus(this.value);

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportStatus.open,
    );
  }

  String get label => switch (this) {
        ReportStatus.open => 'Open',
        ReportStatus.acknowledged => 'Acknowledged',
        ReportStatus.inProgress => 'In Progress',
        ReportStatus.resolved => 'Resolved',
      };
}

class ReportModel {
  const ReportModel({
    required this.id,
    this.taskId,
    this.flightId,
    required this.reportedBy,
    required this.type,
    required this.description,
    required this.severity,
    required this.status,
    required this.direction,
    this.forwardedFromId,
    this.forwarderNotes,
    this.imageUrl,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.resolvedBy,
    this.resolvedAt,
    required this.createdAt,
    this.flight,
    this.reporterName,
    this.reporterRole,
    this.recipientUserIds,
  });

  final String id;
  final String? taskId;
  final String? flightId;
  final String reportedBy;
  final ReportType type;
  final String description;
  final ReportSeverity severity;
  final ReportStatus status;
  final ReportDirection direction;
  final String? forwardedFromId;
  final String? forwarderNotes;
  final String? imageUrl;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final FlightModel? flight;
  final String? reporterName;
  final String? reporterRole;
  final List<String>? recipientUserIds;

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    final flightMap = map['flights'] as Map<String, dynamic>?;
    // Support both 'reporter:reported_by(...)' alias and legacy 'users!reported_by(...)' join
    final userMap = (map['reporter'] ?? map['users']) as Map<String, dynamic>?;
    return ReportModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String?,
      flightId: map['flight_id'] as String?,
      reportedBy: map['reported_by'] as String,
      type: ReportType.fromString(map['type'] as String? ?? ''),
      description: map['description'] as String? ?? '',
      severity: ReportSeverity.fromString(map['severity'] as String? ?? ''),
      status: ReportStatus.fromString(map['status'] as String? ?? ''),
      direction: ReportDirection.fromString(map['direction'] as String? ?? ''),
      forwardedFromId: map['forwarded_from_id'] as String?,
      forwarderNotes: map['forwarder_notes'] as String?,
      imageUrl: map['image_url'] as String?,
      acknowledgedBy: map['acknowledged_by'] as String?,
      acknowledgedAt: map['acknowledged_at'] != null
          ? DateTime.parse(map['acknowledged_at'] as String)
          : null,
      resolvedBy: map['resolved_by'] as String?,
      resolvedAt: map['resolved_at'] != null
          ? DateTime.parse(map['resolved_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      flight: flightMap != null ? FlightModel.fromMap(flightMap) : null,
      reporterName: userMap?['full_name'] as String?,
      reporterRole: userMap?['role'] as String?,
    );
  }

  ReportModel copyWith({
    String? id,
    String? taskId,
    String? flightId,
    String? reportedBy,
    ReportType? type,
    String? description,
    ReportSeverity? severity,
    ReportStatus? status,
    ReportDirection? direction,
    String? forwardedFromId,
    String? forwarderNotes,
    String? imageUrl,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    String? resolvedBy,
    DateTime? resolvedAt,
    DateTime? createdAt,
    FlightModel? flight,
    String? reporterName,
    String? reporterRole,
    List<String>? recipientUserIds,
  }) {
    return ReportModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      flightId: flightId ?? this.flightId,
      reportedBy: reportedBy ?? this.reportedBy,
      type: type ?? this.type,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      forwardedFromId: forwardedFromId ?? this.forwardedFromId,
      forwarderNotes: forwarderNotes ?? this.forwarderNotes,
      imageUrl: imageUrl ?? this.imageUrl,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      flight: flight ?? this.flight,
      reporterName: reporterName ?? this.reporterName,
      reporterRole: reporterRole ?? this.reporterRole,
      recipientUserIds: recipientUserIds ?? this.recipientUserIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'flight_id': flightId,
      'reported_by': reportedBy,
      'type': type.value,
      'description': description,
      'severity': severity.value,
      'status': status.value,
      'direction': direction.toDbString,
    };
  }
}
