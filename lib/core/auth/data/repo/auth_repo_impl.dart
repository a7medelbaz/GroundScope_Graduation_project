import 'package:ground_scope/core/auth/data/models/user_date.dart';

import '../remote/auth_remote_ds.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDs authRemoteDs;

  AuthRepoImpl({required this.authRemoteDs});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final userModel = await authRemoteDs.loginUser(
      email: email,
      password: password,
    );
    return userModel;
  }

  @override
  Future<UserModel> fetchAndCacheUserData({required String email}) async {
    return await authRemoteDs.fetchFreshUserData(email);
  }

  @override
  Future<UserModel?> getLoggedInUser() async {
    return await authRemoteDs.getCachedUserData();
  }

  @override
  Future<void> logout() async {
    await authRemoteDs.logout();
  }
}
