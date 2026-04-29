enum ReportType {
  issue,
  delay,
  damage,
  safety,
  other;

  static ReportType fromString(String value) {
    return switch (value.toLowerCase()) {
      'issue' => ReportType.issue,
      'delay' => ReportType.delay,
      'damage' => ReportType.damage,
      'safety' => ReportType.safety,
      'other' => ReportType.other,
      _ => ReportType.issue,
    };
  }

  String get label => switch (this) {
    ReportType.issue => 'Issue',
    ReportType.delay => 'Delay',
    ReportType.damage => 'Damage',
    ReportType.safety => 'Safety',
    ReportType.other => 'Other',
  };
}

enum ReportSeverity {
  low,
  medium,
  high,
  critical;

  static ReportSeverity fromString(String value) {
    return switch (value.toLowerCase()) {
      'low' => ReportSeverity.low,
      'medium' => ReportSeverity.medium,
      'high' => ReportSeverity.high,
      'critical' => ReportSeverity.critical,
      _ => ReportSeverity.medium,
    };
  }

  String get label => switch (this) {
    ReportSeverity.low => 'Low',
    ReportSeverity.medium => 'Medium',
    ReportSeverity.high => 'High',
    ReportSeverity.critical => 'Critical',
  };
}

enum ReportStatus {
  open,
  acknowledged,
  inProgress,
  resolved;

  static ReportStatus fromString(String value) {
    return switch (value.toLowerCase()) {
      'open' => ReportStatus.open,
      'acknowledged' => ReportStatus.acknowledged,
      'in_progress' => ReportStatus.inProgress,
      'resolved' => ReportStatus.resolved,
      _ => ReportStatus.open,
    };
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
    required this.taskId,
    required this.flightId,
    required this.reportedBy,
    required this.type,
    required this.description,
    required this.severity,
    required this.status,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.resolvedBy,
    this.resolvedAt,
    required this.createdAt,
    this.reportedByName,
    this.acknowledgedByName,
    this.resolvedByName,
    this.flightNumber,
    this.standCode,
  });

  final String id;
  final String taskId;
  final String flightId;
  final String reportedBy;
  final ReportType type;
  final String description;
  final ReportSeverity severity;
  final ReportStatus status;

  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  final DateTime createdAt;

  // Extra display fields (joined data)
  final String? reportedByName;
  final String? acknowledgedByName;
  final String? resolvedByName;
  final String? flightNumber;
  final String? standCode;

  /// Helper getters
  bool get isAcknowledged => status != ReportStatus.open;
  bool get isResolved => status == ReportStatus.resolved;

  String get severityLabel => severity.label;
  String get statusLabel => status.label;
  String get typeLabel => type.label;

  /// Time since created (useful for UI)
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
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
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    String? resolvedBy,
    DateTime? resolvedAt,
    DateTime? createdAt,
    String? reportedByName,
    String? acknowledgedByName,
    String? resolvedByName,
    String? flightNumber,
    String? standCode,
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
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      reportedByName: reportedByName ?? this.reportedByName,
      acknowledgedByName: acknowledgedByName ?? this.acknowledgedByName,
      resolvedByName: resolvedByName ?? this.resolvedByName,
      flightNumber: flightNumber ?? this.flightNumber,
      standCode: standCode ?? this.standCode,
    );
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      flightId: map['flight_id'] as String,
      reportedBy: map['reported_by'] as String,
      type: ReportType.fromString(map['type'] as String),
      description: map['description'] as String,
      severity: ReportSeverity.fromString(map['severity'] as String),
      status: ReportStatus.fromString(map['status'] as String),
      acknowledgedBy: map['acknowledged_by'] as String?,
      acknowledgedAt: map['acknowledged_at'] != null
          ? DateTime.parse(map['acknowledged_at'] as String)
          : null,
      resolvedBy: map['resolved_by'] as String?,
      resolvedAt: map['resolved_at'] != null
          ? DateTime.parse(map['resolved_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      reportedByName: map['reported_by_name'] as String?,
      acknowledgedByName: map['acknowledged_by_name'] as String?,
      resolvedByName: map['resolved_by_name'] as String?,
      flightNumber: map['flight_number'] as String?,
      standCode: map['stand_code'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'flight_id': flightId,
      'reported_by': reportedBy,
      'type': type.name,
      'description': description,
      'severity': severity.name,
      'status': status.name,
      'acknowledged_by': acknowledgedBy,
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
