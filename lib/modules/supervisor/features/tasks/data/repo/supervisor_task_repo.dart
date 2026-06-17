import 'package:ground_scope/core/shared/data/models/task_model.dart';

abstract class SupervisorTaskRepo {
  Future<List<TaskModel>> getTasks(String serviceTypeId);
}
