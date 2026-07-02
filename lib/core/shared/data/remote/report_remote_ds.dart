import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/shared/data/models/report_model.dart';

class ReportRemoteDs {
  ReportRemoteDs({required this.supabaseService});
  final SupabaseService supabaseService;

  Future<ReportModel> submitReport({
    required String reportedBy,
    String? taskId,
    String? flightId,
    required ReportType type,
    required String description,
    required ReportSeverity severity,
    required ReportDirection direction,
    required List<String> recipientUserIds,
    File? imageFile,
    String? forwardedFromId,
    String? forwarderNotes,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      final reportData = await supabaseService.client
          .from('reports')
          .insert({
            'reported_by': reportedBy,
            'task_id': taskId,
            'flight_id': flightId,
            'type': type.value,
            'description': description,
            'severity': severity.value,
            'direction': direction.toDbString,
            'image_url': imageUrl,
            'forwarded_from_id': forwardedFromId,
            'forwarder_notes': forwarderNotes,
          })
          .select()
          .single();

      final reportId = reportData['id'] as String;

      if (recipientUserIds.isNotEmpty) {
        final recipientRows = recipientUserIds
            .map((userId) => {'report_id': reportId, 'user_id': userId})
            .toList();
        await supabaseService.client
            .from('report_recipients')
            .insert(recipientRows);
      }

      return ReportModel.fromMap(reportData);
    } on PostgrestException catch (e, st) {
      debugPrint('[ReportRemoteDs.submitReport] PostgrestException: '
          '${e.message} (code: ${e.code}, details: ${e.details}, hint: ${e.hint})\n$st');
      rethrow;
    } catch (e, st) {
      debugPrint('[ReportRemoteDs.submitReport] failed: $e\n$st');
      rethrow;
    }
  }

  Future<List<ReportModel>> fetchSentReports(String userId) async {
    final data = await supabaseService.client
        .from('reports')
        .select('*, reporter:users!reported_by(full_name, role)')
        .eq('reported_by', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ReportModel.fromMap(e)).toList();
  }

  Future<List<ReportModel>> fetchReceivedReports(String userId) async {
    final data = await supabaseService.client
        .from('report_recipients')
        .select(
          'is_read, report:report_id(*, reporter:users!reported_by(full_name, role))',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map(
          (row) => ReportModel.fromMap(row['report'] as Map<String, dynamic>)
              .copyWith(isRead: row['is_read'] as bool?),
        )
        .toList();
  }

  Future<ReportModel> fetchReportById(String id) async {
    final data = await supabaseService.client
        .from('reports')
        .select('*, reporter:users!reported_by(full_name, role)')
        .eq('id', id)
        .single();
    return ReportModel.fromMap(data);
  }

  Future<List<ReportModel>> fetchAllReports() async {
    final data = await supabaseService.client
        .from('reports')
        .select('*, reporter:users!reported_by(full_name, role)')
        .order('created_at', ascending: false);
    return (data as List).map((e) => ReportModel.fromMap(e)).toList();
  }

  Stream<List<ReportModel>> watchAllReports() {
    return supabaseService.client
        .from('reports')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((_) => fetchAllReports());
  }

  Future<List<ReportModel>> fetchReportsByDirection(
    ReportDirection direction,
  ) async {
    final data = await supabaseService.client
        .from('reports')
        .select('*, reporter:users!reported_by(full_name, role)')
        .eq('direction', direction.toDbString)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ReportModel.fromMap(e)).toList();
  }

  // ─── Legacy (still used by admin dashboard open-report count) ─────────────

  Future<int> countOpenReports() async {
    try {
      final data = await supabaseService.client
          .from('reports')
          .select('id')
          .eq('status', 'open');
      return (data as List).length;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> markAsRead({
    required String reportId,
    required String userId,
  }) async {
    await supabaseService.client
        .from('report_recipients')
        .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
        .eq('report_id', reportId)
        .eq('user_id', userId);
  }

  Future<void> acknowledgeReport({
    required String reportId,
    required String userId,
  }) async {
    await supabaseService.client
        .from('reports')
        .update({
          'status': ReportStatus.acknowledged.value,
          'acknowledged_by': userId,
          'acknowledged_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reportId);
  }

  Future<void> resolveReport({
    required String reportId,
    required String userId,
  }) async {
    await supabaseService.client
        .from('reports')
        .update({
          'status': ReportStatus.resolved.value,
          'resolved_by': userId,
          'resolved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reportId);
  }

  Future<ReportModel> forwardReport({
    required String originalReportId,
    required ReportModel original,
    required String supervisorId,
    required String forwarderNotes,
    required List<String> adminUserIds,
  }) async {
    return submitReport(
      reportedBy: supervisorId,
      taskId: original.taskId,
      flightId: original.flightId,
      type: original.type,
      description: original.description,
      severity: original.severity,
      direction: ReportDirection.supervisorToAdmin,
      recipientUserIds: adminUserIds,
      forwardedFromId: originalReportId,
      forwarderNotes: forwarderNotes,
    );
  }

  // ─── Real-time ─────────────────────────────────────────────────────────────

  Stream<List<ReportModel>> watchReceivedReports(String userId) {
    return supabaseService.client
        .from('report_recipients')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((rows) async {
          if (rows.isEmpty) return <ReportModel>[];
          final reportIds = rows.map((r) => r['report_id'] as String).toList();
          final isReadByReportId = {
            for (final r in rows) r['report_id'] as String: r['is_read'] as bool?,
          };
          final reports = await supabaseService.client
              .from('reports')
              .select('*, reporter:users!reported_by(full_name, role)')
              .inFilter('id', reportIds)
              .order('created_at', ascending: false);
          return (reports as List)
              .map((e) => ReportModel.fromMap(e)
                  .copyWith(isRead: isReadByReportId[e['id'] as String]))
              .toList();
        });
  }

  Stream<int> watchUnreadCount(String userId) {
    return supabaseService.client
        .from('report_recipients')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.where((r) => r['is_read'] == false).length);
  }

  // ─── Image upload ──────────────────────────────────────────────────────────

  Future<String> _uploadImage(File file) async {
    final originalName = file.path.split('/').last;
    final sanitized = originalName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$sanitized';
    await supabaseService.client.storage.from('reports').upload(fileName, file);
    return supabaseService.client.storage
        .from('reports')
        .getPublicUrl(fileName);
  }
}
