import '../../../../../../core/error/models/app_error.dart';
import '../../../../../../core/service/secure_storage.dart';
import '../../../../../../core/shared/data/models/task_model.dart';
import '../remote/home_remote_ds.dart';
import 'home_repo.dart';

class HomeRepoImpl implements HomeRepo {
  final HomeRemoteDs remoteDs;
  final SecureStorage secureStorage;

  HomeRepoImpl({required this.remoteDs, required this.secureStorage});

  @override
  Future<List<TaskModel>> fetchWorkerTasks({required String unitId}) async {
    try {
      return await remoteDs.fetchWorkerTasks(unitId);
    } catch (e) {
      throw e is AppError ? e : AppError.unknown();
    }
  }
}
