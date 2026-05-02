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
    required this.taskId,
    required this.flightId,
    required this.reportedBy,
    required this.type,
    required this.description,
    required this.severity,
    required this.status,
    this.imageUrl,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.resolvedBy,
    this.resolvedAt,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String flightId;
  final String reportedBy;
  final ReportType type;
  final String description;
  final ReportSeverity severity;
  final ReportStatus status;
  final String? imageUrl;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      taskId: map['task_id'],
      flightId: map['flight_id'],
      reportedBy: map['reported_by'],
      type: ReportType.fromString(map['type']),
      description: map['description'],
      severity: ReportSeverity.fromString(map['severity']),
      status: ReportStatus.fromString(map['status']),
      imageUrl: map['image_url'],
      acknowledgedBy: map['acknowledged_by'],
      acknowledgedAt: map['acknowledged_at'] != null
          ? DateTime.parse(map['acknowledged_at'])
          : null,
      resolvedBy: map['resolved_by'],
      resolvedAt: map['resolved_at'] != null
          ? DateTime.parse(map['resolved_at'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
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
    };
  }
}
