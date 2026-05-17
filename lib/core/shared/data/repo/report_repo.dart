// ── report_repo.dart ──────────────────────────────────────────────────────────
import 'dart:io';
import '../../../../core/shared/data/models/report_model.dart';

abstract class ReportRepo {
  Future<ReportModel> submitReport({
    required String taskId,
    required String flightId,
    required String userId,
    required ReportType type,
    required String description,
    required ReportSeverity severity,
    File? imageFile,
  });

  Future<List<ReportModel>> getReportsByTask(String taskId);
  Future<List<ReportModel>> getMyReports(String userId);
  Future<List<ReportModel>> fetchAllReports();
  Future<void> deleteReport(String id);
}
