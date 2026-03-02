import 'package:ground_scope/modules/worker/features/home/data/models/task_model.dart';

class TaskFilter {
  final TaskStatus? status;
  final int? hours;

  const TaskFilter({this.status, this.hours});

  bool get isActive => status != null || hours != null;

  TaskFilter copyWith({
    TaskStatus? status,
    int? hours,
    bool clearStatus = false,
    bool clearHours = false,
  }) {
    return TaskFilter(
      status: clearStatus ? null : status ?? this.status,
      hours: clearHours ? null : hours ?? this.hours,
    );
  }

  static const TaskFilter empty = TaskFilter();
}
