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

  Future<List<String>> fetchSupervisorsByServiceType(
      String serviceTypeId) async {
    try {
      final data = await _supabase.client
          .from('users')
          .select('id')
          .eq('role', 'supervisor')
          .eq('service_type_id', serviceTypeId)
          .eq('is_active', true);
      return (data as List).map((e) => e['id'] as String).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<List<String>> fetchAllAdmins() async {
    try {
      final data = await _supabase.client
          .from('users')
          .select('id')
          .eq('role', 'admin')
          .eq('is_active', true);
      return (data as List).map((e) => e['id'] as String).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Returns the login-account user id(s) tied to this unit (i.e. the unit
  /// manager account(s), via `users.unit_id`) — the correct target for
  /// notifications. Note: `unit_members` is a crew roster (name/phone/
  /// position) with no `user_id` column; it has no login accounts.
  Future<List<String>> fetchUnitMemberIds(String unitId) async {
    try {
      final data = await _supabase.client
          .from('users')
          .select('id')
          .eq('unit_id', unitId)
          .eq('is_active', true);
      return (data as List).map((e) => e['id'] as String).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<List<String>> fetchAllNonAdminUserIds() async {
    try {
      final data = await _supabase.client
          .from('users')
          .select('id')
          .neq('role', 'admin')
          .eq('is_active', true);
      return (data as List).map((e) => e['id'] as String).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<List<String>> fetchSupervisorIds() async {
    try {
      final data = await _supabase.client
          .from('users')
          .select('id')
          .eq('role', 'supervisor')
          .eq('is_active', true);
      return (data as List).map((e) => e['id'] as String).toList();
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
