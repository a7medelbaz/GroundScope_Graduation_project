import 'dart:io';

import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/shared/data/remote/user_remote_ds.dart';

class SupervisorReportsRemoteDs {
  const SupervisorReportsRemoteDs(this._supabaseService, this._userRemoteDs);

  final SupabaseService _supabaseService;
  final UserRemoteDs _userRemoteDs;

  /// Fetches all reports received by this supervisor in one round trip and
  /// splits them into (workerInbox, fromAdmin) — inbox is worker alerts,
  /// fromAdmin is admin-to-supervisor + admin broadcasts.
  Future<(List<ReportModel>, List<ReportModel>)> fetchReceived(
    String supervisorId,
  ) async {
    final data = await _supabaseService.client
        .from('report_recipients')
        .select(
          'is_read, report:report_id(*, reporter:reported_by(full_name, role))',
        )
        .eq('user_id', supervisorId)
        .order('created_at', ascending: false);

    final received = (data as List)
        .map(
          (row) => ReportModel.fromMap(row['report'] as Map<String, dynamic>)
              .copyWith(isRead: row['is_read'] as bool?),
        )
        .toList();

    final inbox = received
        .where((r) => r.direction == ReportDirection.workerToSupervisor)
        .toList();
    final fromAdmin = received
        .where(
          (r) =>
              r.direction == ReportDirection.adminToSupervisor ||
              r.direction == ReportDirection.adminBroadcast,
        )
        .toList();

    return (inbox, fromAdmin);
  }

  Future<List<ReportModel>> fetchSent(String supervisorId) async {
    final data = await _supabaseService.client
        .from('reports')
        .select('*, reporter:reported_by(full_name, role)')
        .eq('reported_by', supervisorId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ReportModel.fromMap(e)).toList();
  }

  Future<(ReportModel, List<String>)> sendToUnit({
    required String supervisorId,
    required String unitId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, supervisorId);
    }

    final unitMemberIds = await _userRemoteDs.fetchUnitMemberIds(unitId);

    final reportData = await _supabaseService.client
        .from('reports')
        .insert({
          'reported_by': supervisorId,
          'type': type.value,
          'description': description,
          'severity': severity.value,
          'direction': ReportDirection.supervisorToUnit.toDbString,
          'image_url': imageUrl,
        })
        .select()
        .single();

    final reportId = reportData['id'] as String;

    if (unitMemberIds.isNotEmpty) {
      await _supabaseService.client
          .from('report_recipients')
          .insert(
            unitMemberIds
                .map((uid) => {'report_id': reportId, 'user_id': uid})
                .toList(),
          );
    }

    return (ReportModel.fromMap(reportData), unitMemberIds);
  }

  Future<(ReportModel, List<String>)> broadcast({
    required String supervisorId,
    required String serviceTypeId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, supervisorId);
    }

    // Fetch all unit members in this service type's units
    final unitsData = await _supabaseService.client
        .from('units')
        .select('id')
        .eq('service_type_id', serviceTypeId);
    final unitIds = (unitsData as List).map((e) => e['id'] as String).toList();

    final allMemberIds = <String>{};
    for (final unitId in unitIds) {
      final ids = await _userRemoteDs.fetchUnitMemberIds(unitId);
      allMemberIds.addAll(ids);
    }

    final reportData = await _supabaseService.client
        .from('reports')
        .insert({
          'reported_by': supervisorId,
          'type': type.value,
          'description': description,
          'severity': severity.value,
          'direction': ReportDirection.supervisorToUnit.toDbString,
          'image_url': imageUrl,
        })
        .select()
        .single();

    final reportId = reportData['id'] as String;

    if (allMemberIds.isNotEmpty) {
      await _supabaseService.client
          .from('report_recipients')
          .insert(
            allMemberIds
                .map((uid) => {'report_id': reportId, 'user_id': uid})
                .toList(),
          );
    }

    return (ReportModel.fromMap(reportData), allMemberIds.toList());
  }

  Future<(ReportModel, List<String>)> forwardToAdmin({
    required ReportModel original,
    required String supervisorId,
    required String notes,
  }) async {
    final adminIds = await _userRemoteDs.fetchAllAdmins();

    final reportData = await _supabaseService.client
        .from('reports')
        .insert({
          'reported_by': supervisorId,
          'task_id': original.taskId,
          'flight_id': original.flightId,
          'type': original.type.value,
          'description': original.description,
          'severity': original.severity.value,
          'direction': ReportDirection.supervisorToAdmin.toDbString,
          'forwarded_from_id': original.id,
          'forwarder_notes': notes,
        })
        .select()
        .single();

    final reportId = reportData['id'] as String;

    if (adminIds.isNotEmpty) {
      await _supabaseService.client
          .from('report_recipients')
          .insert(
            adminIds
                .map((uid) => {'report_id': reportId, 'user_id': uid})
                .toList(),
          );
    }

    return (ReportModel.fromMap(reportData), adminIds);
  }

  Future<void> markAsRead({
    required String reportId,
    required String supervisorId,
  }) async {
    await _supabaseService.client
        .from('report_recipients')
        .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
        .eq('report_id', reportId)
        .eq('user_id', supervisorId);
  }

  Future<void> acknowledgeReport({
    required String reportId,
    required String supervisorId,
  }) async {
    await _supabaseService.client
        .from('reports')
        .update({
          'status': ReportStatus.acknowledged.value,
          'acknowledged_by': supervisorId,
          'acknowledged_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reportId);
  }

  Future<void> resolveReport({
    required String reportId,
    required String supervisorId,
  }) async {
    await _supabaseService.client
        .from('reports')
        .update({
          'status': ReportStatus.resolved.value,
          'resolved_by': supervisorId,
          'resolved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reportId);
  }

  Stream<(List<ReportModel>, List<ReportModel>)> watchReceived(
    String supervisorId,
  ) {
    return _supabaseService.client
        .from('report_recipients')
        .stream(primaryKey: ['id'])
        .eq('user_id', supervisorId)
        .asyncMap((_) => fetchReceived(supervisorId));
  }

  Future<String> _uploadImage(File file, String userId) async {
    final originalName = file.path.split('/').last;
    final sanitized = originalName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$sanitized';
    await _supabaseService.client.storage
        .from('reports')
        .upload(fileName, file);
    return _supabaseService.client.storage
        .from('reports')
        .getPublicUrl(fileName);
  }
}
