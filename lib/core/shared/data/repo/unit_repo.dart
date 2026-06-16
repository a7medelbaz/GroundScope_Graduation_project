import '../models/unit_model.dart';
import '../models/unit_profile_model.dart';

abstract class UnitRepo {
  Future<UnitModel> getUnitData({required String unitId});
  Future<UnitProfileModel> fetchUnitById(String unitId);
  Future<int> countActiveUnits();
}
