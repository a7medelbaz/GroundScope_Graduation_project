import 'package:ground_scope/core/shared/data/models/task_model.dart';

class TaskAssignmentInput {
  const TaskAssignmentInput({
    required this.flightId,
    required this.serviceTypeId,
    required this.unitId,
    required this.priority,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.notes,
  });

  final String flightId;
  final String serviceTypeId;
  final String unitId;
  final TaskPriority priority;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String? notes;
}
