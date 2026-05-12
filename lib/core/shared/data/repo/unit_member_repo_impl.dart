import '../../../error/models/app_error.dart';
import '../../../error/types/error_handler.dart';
import '../models/unit_member_model.dart';
import '../remote/unit_member_remote_ds.dart';
import 'unit_member_repo.dart';

class UnitMemberRepoImpl implements UnitMemberRepo {
  const UnitMemberRepoImpl({required this.unitMemberRemoteDs});

  final UnitMemberRemoteDs unitMemberRemoteDs;

  @override
  Future<List<UnitMemberModel>> fetchUnitMembers(String unitId) async {
    try {
      return await unitMemberRemoteDs.fetchUnitMembers(unitId);
    } on AppError {
      rethrow;
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }
}
