
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/remote/unit_remote_ds.dart';

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
}
