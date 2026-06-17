import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_type.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRemoteDs {
  UserRemoteDs(this._supabase);

  final SupabaseService _supabase;

  static const _joinSelect = '*, service_types(id, name), units(id, name)';

  /// Creates a Supabase Auth account + public.users record.
  /// NOTE: auth.admin requires the Supabase client to be configured
  /// with the service role key. With anon key, signUp() is used instead,
  /// which may require email confirmation depending on your project settings.
  Future<UserModel> createAccount({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? serviceTypeId,
    String? unitId,
  }) async {
    try {
      final response = await _supabase.client.functions.invoke(
        'create-user',
        body: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'role': role.toDbString,
          'service_type_id': serviceTypeId,
          'unit_id': unitId,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] as String?;
        throw AppError(
          type: ErrorType.internalServer,
          messageKey: error ?? 'account_creation_failed',
        );
      }

      return UserModel.fromMap(response.data['user'] as Map<String, dynamic>);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.unknown();
    }
  }

  Future<void> resetPassword({
    required String authId,
    required String newPassword,
  }) async {
    try {
      final response = await _supabase.client.functions.invoke(
        'reset-user-password',
        body: {'auth_id': authId, 'new_password': newPassword},
      );

      if (response.status != 200) {
        throw const AppError(
          type: ErrorType.internalServer,
          messageKey: 'reset_failed',
        );
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.unknown();
    }
  }

  /// Fetches all non-admin users with joined service_types and units.
  Future<List<UserModel>> fetchAll({UserRole? roleFilter}) async {
    try {
      final baseQuery = _supabase.client
          .from('users')
          .select(_joinSelect)
          .neq('role', 'admin');

      final data = roleFilter != null
          ? await baseQuery
                .eq('role', roleFilter.toDbString)
                .order('created_at', ascending: false)
          : await baseQuery.order('created_at', ascending: false);

      return (data as List)
          .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Toggles the is_active flag for a user.
  Future<void> setActive(String userId, bool isActive) async {
    try {
      await _supabase.client
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }
}
