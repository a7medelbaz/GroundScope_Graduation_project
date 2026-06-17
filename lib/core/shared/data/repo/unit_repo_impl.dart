import '../../../error/models/app_error.dart';
import '../../../error/types/error_handler.dart';
import '../models/task_model.dart';
import '../models/unit_model.dart';
import '../models/unit_profile_model.dart';
import '../remote/unit_remote_ds.dart';
import 'unit_repo.dart';

class UnitRepoImpl implements UnitRepo {
  const UnitRepoImpl({required this.unitRemoteDs});

  final UnitRemoteDs unitRemoteDs;

  @override
  Future<UnitModel> getUnitData({required String unitId}) async {
    try {
      return await unitRemoteDs.fetchUnitData(unitId);
    } on AppError {
      rethrow;
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<UnitProfileModel> fetchUnitById(String unitId) async {
    try {
      return await unitRemoteDs.fetchUnitById(unitId);
    } on AppError {
      rethrow;
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<int> countActiveUnits() => unitRemoteDs.countActiveUnits();

  @override
  Future<UnitModel?> fetchUnitModelById(String unitId) async {
    try {
      return await unitRemoteDs.fetchUnitModelById(unitId);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<UnitModel>> fetchAll({String? serviceTypeId}) async {
    try {
      return await unitRemoteDs.fetchAll(serviceTypeId: serviceTypeId);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UnitModel> create(UnitModel model) async {
    try {
      return await unitRemoteDs.create(model);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UnitModel> update(UnitModel model) async {
    try {
      return await unitRemoteDs.update(model);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateStatus(String unitId, UnitStatus status) async {
    try {
      await unitRemoteDs.updateStatus(unitId, status);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<TaskModel>> fetchUnitTasks(String unitId) async {
    try {
      return await unitRemoteDs.fetchUnitTasks(unitId);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
