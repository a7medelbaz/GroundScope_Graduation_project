import 'package:flutter/material.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../utils/secure_storage.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  final _secureStorage = SecureStorage();
  Future<AuthResponse> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final userId = response.user?.id;
      if (userId != null) {
        _secureStorage.saveString(key: 'user_id', value: userId);
      }

      debugPrint('✅ User logged in successfully: ${response.user?.id}');
      return response;
    } catch (e) {
      final appError = ErrorHandler.handle(e);
      debugPrint('❌ Login failed: ${appError.message}');
      throw AppError(
        message: appError.message,
        type: appError.type,
        code: appError.code,
        originalError: appError.originalError,
      );
    }
  }

  /// Fetch USer By Id
  Future<Map<String, dynamic>?> fetchUserProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('userdata')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      final appError = ErrorHandler.handle(e);
      debugPrint('❌ Login failed: ${appError.message}');
      throw AppError(
        message: appError.message,
        type: appError.type,
        code: appError.code,
        originalError: appError.originalError,
      );
    }
  }
}
