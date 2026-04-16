import 'package:ground_scope/core/shared/data/models/unit_model.dart';

abstract class UnitRepo {
  Future<UnitModel> getUnitData({required String unitId});
}
