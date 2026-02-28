import 'dart:convert';

import '../models/user_date.dart';
import '../../../config/app_constants.dart';
import '../../../error/models/app_error.dart';
import '../../../error/types/error_handler.dart';
import '../../../networking/supabase_service.dart';
import '../../../service/secure_storage.dart';
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
