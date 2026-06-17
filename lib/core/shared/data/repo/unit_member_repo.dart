import '../models/unit_member_model.dart';

abstract class UnitMemberRepo {
  Future<List<UnitMemberModel>> fetchUnitMembers(String unitId);
  Future<UnitMemberModel> create(UnitMemberModel model);
  Future<UnitMemberModel> update(UnitMemberModel model);
  Future<void> deactivate(String memberId);
}
