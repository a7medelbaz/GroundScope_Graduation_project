// lib/core/shared/data/models/task_pause_model.dart

import 'package:equatable/equatable.dart';

class TaskPauseModel extends Equatable {
  const TaskPauseModel({
    required this.id,
    required this.taskId,
    required this.pausedAt,
    this.resumedAt,
    this.reason,
    this.pausedBy,
  });

  final String id;
  final String taskId;
  final DateTime pausedAt;
  final DateTime? resumedAt;
  final String? reason;
  final String? pausedBy;

  bool get isActive => resumedAt == null;

  Duration get duration {
    final end = resumedAt ?? DateTime.now();
    return end.difference(pausedAt);
  }

  TaskPauseModel copyWith({
    String? id,
    String? taskId,
    DateTime? pausedAt,
    DateTime? resumedAt,
    String? reason,
    String? pausedBy,
  }) {
    return TaskPauseModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      pausedAt: pausedAt ?? this.pausedAt,
      resumedAt: resumedAt ?? this.resumedAt,
      reason: reason ?? this.reason,
      pausedBy: pausedBy ?? this.pausedBy,
    );
  }

  factory TaskPauseModel.fromMap(Map<String, dynamic> map) {
    return TaskPauseModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      pausedAt: DateTime.parse(map['paused_at'] as String),
      resumedAt: map['resumed_at'] != null
          ? DateTime.parse(map['resumed_at'] as String)
          : null,
      reason: map['reason'] as String?,
      pausedBy: map['paused_by'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, taskId, pausedAt, resumedAt, reason];
}
