import 'dart:convert';

import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/config/app_constants.dart';
import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/service/secure_storage.dart';
import 'package:ground_scope/modules/worker/features/home/data/remote/home_remote_ds.dart';
import 'package:ground_scope/modules/worker/features/home/data/repo/home_repo.dart';

class HomeRepoImpl implements HomeRepo {
  final HomeRemoteDs remoteDs;
  final SecureStorage secureStorage;

  HomeRepoImpl({required this.remoteDs, required this.secureStorage});

  @override
  Future<List<TaskModel>> fetchWorkerTasks() async {
    final String? jsonString = await secureStorage.read(
      key: AppConstants.userDataKey,
    );
    if (jsonString == null || jsonString.isEmpty) {
      throw AppError.unauthorized();
    }

    try {
      final Map<String, dynamic> userMap = jsonDecode(jsonString);
      final user = UserModel.fromJson(userMap);
      return await remoteDs.fetchWorkerTasks(user.id);
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }
}
