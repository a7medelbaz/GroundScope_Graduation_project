import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';

class SupervisorReportsRemoteDs {
  const SupervisorReportsRemoteDs(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<List<ReportModel>> fetchReports(String serviceTypeId) async {
    final rows = await _supabaseService.client
        .from('reports')
        .select('*, flights(*), users!reported_by(full_name, role), tasks!inner(service_type_id)')
        .eq('tasks.service_type_id', serviceTypeId)
        .order('created_at', ascending: false);
    return rows.map((row) => ReportModel.fromMap(row)).toList();
  }

  Future<void> acknowledgeReport({
    required String reportId,
    required String supervisorId,
  }) async {
    await _supabaseService.client.from('reports').update({
      'status': ReportStatus.acknowledged.value,
      'acknowledged_by': supervisorId,
      'acknowledged_at': DateTime.now().toIso8601String(),
    }).eq('id', reportId);
  }

  Future<void> resolveReport({
    required String reportId,
    required String supervisorId,
  }) async {
    await _supabaseService.client.from('reports').update({
      'status': ReportStatus.resolved.value,
      'resolved_by': supervisorId,
      'resolved_at': DateTime.now().toIso8601String(),
    }).eq('id', reportId);
  }
}
