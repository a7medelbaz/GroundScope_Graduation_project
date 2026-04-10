import 'dart:convert';

import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/service/secure_storage.dart';

import '../../../config/app_constants.dart';
import '../../../error/models/app_error.dart';
import '../../../networking/supabase_service.dart';

class AuthRemoteDs {
  final SupabaseService supabaseService;
  final SecureStorage secureStorage;
  AuthRemoteDs({required this.supabaseService, required this.secureStorage});

  /// Authenticates user with Supabase Auth and returns full custom user profile
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Authenticate with Supabase Auth (creates session + JWT)
      final authResponse = await supabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (authResponse.user == null || authResponse.session == null) {
        throw AppError.unauthorized();
      }

      // Fetch custom user profile from public.users table
      final userDataMap = await supabaseService.client
          .from('users')
          .select()
          .eq('email', email.trim())
          .maybeSingle();

      if (userDataMap == null) {
        throw AppError.unauthorized();
      }

      final userModel = UserModel.fromJson(userDataMap);
      await secureStorage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(userModel.toJson()),
      );

      print('✅ Login successful → ${userModel.email}');
      return userModel;
    } catch (e) {
      print('❌ Login failed for $email: $e');
      rethrow;
    }
  }

  /// Get user from local secure storage
  Future<UserModel?> getCachedUserData() async {
    final raw = await secureStorage.read(key: AppConstants.userDataKey);
    if (raw == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(raw));
    } catch (e) {
      await secureStorage.delete(key: AppConstants.userDataKey);
      return null;
    }
  }

  /// Refresh user data from database and update cache
  Future<UserModel> fetchFreshUserData(String email) async {
    try {
      final userDataMap = await supabaseService.client
          .from('users')
          .select()
          .eq('email', email.trim())
          .maybeSingle();

      if (userDataMap == null) {
        throw AppError.unauthorized();
      }

      final userModel = UserModel.fromJson(userDataMap);

      await secureStorage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(userModel.toJson()),
      );

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout and clear local data
  Future<void> logout() async {
    try {
      await supabaseService.client.auth.signOut();
      await secureStorage.delete(key: AppConstants.userDataKey);
      print('✅ User logged out successfully');
    } catch (e) {
      print('⚠️ Logout error: $e');
      rethrow;
    }
  }
}
