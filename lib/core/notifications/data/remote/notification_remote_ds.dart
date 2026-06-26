import 'package:flutter/material.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRemoteDs {
  NotificationRemoteDs(this._supabase);
  final SupabaseService _supabase;

  Future<List<NotificationModel>> fetchMyNotifications() async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) return [];

      final userData = await _supabase.client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .single();

      final userId = userData['id'] as String;

      final data = await _supabase.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (data as List)
          .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<int> fetchUnreadCount() async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) return 0;

      final userData = await _supabase.client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .single();

      final userId = userData['id'] as String;

      final data = await _supabase.client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? referenceId,
    String? referenceType,
  }) async {
    try {
      await _supabase.client.functions.invoke(
        'send-notification',
        body: {
          'user_id': userId,
          'title': title,
          'body': body,
          'type': type.toDbString,
          'reference_id': referenceId,
          'reference_type': referenceType,
        },
      );
    } catch (e) {
      debugPrint('Notification send failed: $e');
    }
  }

  Stream<int> watchUnreadCount(String userId) {
    return _supabase.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.where((r) => r['is_read'] == false).length);
  }
}
