import 'package:ground_scope/core/shared/data/models/task_model.dart';
import '../remote/supervisor_task_remote_ds.dart';
import 'supervisor_task_repo.dart';

class SupervisorTaskRepoImpl implements SupervisorTaskRepo {
  const SupervisorTaskRepoImpl(this._ds);

  final SupervisorTaskRemoteDs _ds;

  @override
  Future<List<TaskModel>> getTasks(String serviceTypeId) =>
      _ds.fetchTasks(serviceTypeId);
}
