import 'dart:convert';

import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/config/app_constants.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/service/secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDs {
  final SupabaseService supabaseService;
  final SecureStorage secureStorage;

  AuthRemoteDs({required this.supabaseService, required this.secureStorage});

  Future<AuthResponse> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      return await supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  Future<UserData?> getCachedUserData() async {
    final raw = await secureStorage.read(key: AppConstants.userDataKey);
    if (raw == null) return null;
    return UserData.fromJson(jsonDecode(raw));
  }

  Future<UserData> fetchAndCacheUserData() async {
    try {
      final userId = supabaseService.currentUser?.id;
      if (userId == null || userId.isEmpty) throw AppError.unauthorized();

      final userDataMap = await supabaseService.client
          .from('userdata')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (userDataMap == null) throw AppError.unauthorized();

      final userData = UserData.fromJson(userDataMap);
      await secureStorage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(userData.toJson()),
      ); // saves everything
      return userData;
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  Future<void> logout() async {
    try {
      await supabaseService.signOut();
      await secureStorage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }
}
