import 'dart:io';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorAddReportRemoteDs {
  const SupervisorAddReportRemoteDs(this._supabaseService);
  final SupabaseService _supabaseService;

  Future<void> submitReport({
    required String supervisorId,
    required String reportedTo,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, supervisorId);
    }

    try {
      await _supabaseService.client.from('reports').insert({
        'reported_by': supervisorId,
        'type': type.value,
        'description': description,
        'severity': severity.value,
        'status': ReportStatus.open.value,
        'reported_to': reportedTo,
        'image_url': imageUrl,
      });
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } on StorageException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<String> _uploadImage(File file, String supervisorId) async {
    final fileName =
        'reports/$supervisorId/supervisor/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabaseService.client.storage
        .from('report-images')
        .upload(
          fileName,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return _supabaseService.client.storage
        .from('report-images')
        .getPublicUrl(fileName);
  }
}
