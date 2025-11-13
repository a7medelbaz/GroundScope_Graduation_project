import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/secure_storage.dart';

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
        await _secureStorage.saveUserId(userId);
      }

      debugPrint(
        '✅ User logged in successfully: ${response.user?.id}',
      );
      return response;
    } on AuthException catch (e) {
      debugPrint("❌ Login failed: ${e.message}");
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      debugPrint("❌ Unexpected error during login: $e");
      throw Exception('Unexpected error during login: $e');
    }
  }

  /// Fetch USer By Id
  Future<Map<String, dynamic>?> fetchUserProfileById(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('userdata')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      debugPrint("❌ Error fetching user session data: $e");
      return null;
    }
  }
}
