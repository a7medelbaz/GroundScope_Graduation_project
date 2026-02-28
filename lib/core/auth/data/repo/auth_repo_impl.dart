import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/auth/data/remote/auth_remote_ds.dart';
import 'package:ground_scope/core/auth/data/repo/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
