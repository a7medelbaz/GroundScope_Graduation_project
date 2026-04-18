import '../models/unit_model.dart';

abstract class UnitRepo {
  Future<UnitModel> getUnitData({required String unitId});
}
