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
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UnitMemberModel> create(UnitMemberModel model) async {
    try {
      return await unitMemberRemoteDs.create(model);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UnitMemberModel> update(UnitMemberModel model) async {
    try {
      return await unitMemberRemoteDs.update(model);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deactivate(String memberId) async {
    try {
      await unitMemberRemoteDs.deactivate(memberId);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
