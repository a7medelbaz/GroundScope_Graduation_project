import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_date.dart';
import '../remote/auth_remote_ds.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDs authRemoteDs;

  AuthRepoImpl({required this.authRemoteDs});

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await authRemoteDs.loginUser(email: email, password: password);
  }

  @override
  Future<UserData> fetchAndCacheUserData() async {
    return await authRemoteDs.fetchAndCacheUserData();
  }

  @override
  Future<UserData?> getLoggedInUser() async {
    return await authRemoteDs.getCachedUserData();
  }

  @override
  Future<void> logout() => authRemoteDs.logout();
}
