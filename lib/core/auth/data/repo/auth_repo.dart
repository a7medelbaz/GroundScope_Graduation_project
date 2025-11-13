import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../service/auth_service.dart';

class AuthRepo {
  final AuthService _authService;

  AuthRepo({required AuthService authService})
    : _authService = authService;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.loginUser(
        email: email,
        password: password,
      );
    } catch (e, stackTrace) {
      debugPrint('Login error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    try {
      return await _authService.fetchUserProfileById(userId);
    } catch (e, stackTrace) {
      debugPrint('Fetch user data error: $e\n$stackTrace');
      return null;
    }
  }
}
