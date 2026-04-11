import 'dart:convert';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/config/app_constants.dart';
import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/data/models/unit_model.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/secure_storage.dart';
import 'package:ground_scope/modules/worker/features/home/data/repo/home_repo.dart';
import '../remote/home_remote_ds.dart';

class HomeRepoImpl implements HomeRepo {
  final HomeRemoteDs remoteDs;
  final SecureStorage secureStorage;

  HomeRepoImpl({required this.remoteDs, required this.secureStorage});

  @override
  Future<List<TaskModel>> fetchWorkerTasks() async {
    try {
      final user = await _getAuthenticatedUser();
      if (user.unitId == null) throw AppError.unauthorized("No unit assigned.");
      return await remoteDs.fetchWorkerTasks(user.unitId!);
    } catch (e) {
      throw e is AppError ? e : AppError.unknown();
    }
  }

  @override
  Future<UnitModel> getUnitData() async {
    try {
      final user = await _getAuthenticatedUser();
      return await remoteDs.fetchUnitData(user.id);
    } catch (e) {
      throw e is AppError ? e : AppError.unknown();
    }
  }

  Future<UserModel> _getAuthenticatedUser() async {
    final String? jsonString = await secureStorage.read(
      key: AppConstants.userDataKey,
    );
    if (jsonString == null || jsonString.isEmpty) throw AppError.unauthorized();
    try {
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      throw AppError.unknown();
    }
  }
}
