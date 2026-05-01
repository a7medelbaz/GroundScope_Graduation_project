import 'dart:io';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/shared/data/models/report_model.dart';

class ReportRemoteDs {
  ReportRemoteDs({required this.supabaseService});
  final SupabaseService supabaseService;
  Future<ReportModel> submitReport({
    required String taskId,
    required String flightId,
    required String userId,
    required ReportType type,
    required String description,
    required ReportSeverity severity,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadReportImage(imageFile, taskId);
    }

    // 2. Insert report into DB
    final data = await supabaseService.client
        .from('reports')
        .insert({
          'task_id': taskId,
          'flight_id': flightId,
          'reported_by': userId,
          'type': type.value,
          'description': description,
          'severity': severity.value,
          'status': ReportStatus.open.value,
          'image_url': ?imageUrl,
        })
        .select()
        .single();
    print('auth uid: ${supabaseService.client.auth.currentUser?.id}');
    print('reported_by: $userId');
    return ReportModel.fromMap(data);
  }

  // ── Fetch reports for a specific task ─────────────────────────────────────
  Future<List<ReportModel>> getReportsByTask(String taskId) async {
    final data = await supabaseService.client
        .from('reports')
        .select()
        .eq('task_id', taskId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => ReportModel.fromMap(e)).toList();
  }

  Future<List<ReportModel>> getMyReports(String userId) async {
    final data = await supabaseService.client
        .from('reports')
        .select()
        .eq('reported_by', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => ReportModel.fromMap(e)).toList();
  }

  Future<String> _uploadReportImage(File file, String taskId) async {
    final userId = supabaseService.currentUser!.id;
    final fileName =
        'reports/$userId/$taskId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabaseService.client.storage
        .from('report-images')
        .upload(
          fileName,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return supabaseService.client.storage
        .from('report-images')
        .getPublicUrl(fileName);
  }
}
