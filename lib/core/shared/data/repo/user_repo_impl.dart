import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/shared/data/remote/user_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/user_repo.dart';

class UserRepoImpl implements UserRepo {
  UserRepoImpl(this._ds);

  final UserRemoteDs _ds;

  @override
  Future<UserModel> createAccount({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? serviceTypeId,
    String? unitId,
  }) =>
      _ds.createAccount(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        serviceTypeId: serviceTypeId,
        unitId: unitId,
      );

  @override
  Future<void> resetPassword({
    required String authId,
    required String newPassword,
  }) =>
      _ds.resetPassword(authId: authId, newPassword: newPassword);

  @override
  Future<List<UserModel>> fetchAll({UserRole? roleFilter}) =>
      _ds.fetchAll(roleFilter: roleFilter);

  @override
  Future<void> setActive(String userId, bool isActive) =>
      _ds.setActive(userId, isActive);
}
