import 'dart:io';
import '../../../../core/shared/data/models/report_model.dart';

abstract class ReportRepo {
  // Submit
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
  });

  // Fetch
  Future<List<ReportModel>> fetchSentReports(String userId);
  Future<List<ReportModel>> fetchReceivedReports(String userId);
  Future<ReportModel> fetchReportById(String id);
  Future<List<ReportModel>> fetchAllReports();
  Stream<List<ReportModel>> watchAllReports();
  Future<List<ReportModel>> fetchReportsByDirection(ReportDirection direction);

  // Legacy
  Future<int> countOpenReports();

  // Actions
  Future<void> markAsRead({required String reportId, required String userId});
  Future<void> acknowledgeReport(
      {required String reportId, required String userId});
  Future<void> resolveReport(
      {required String reportId, required String userId});
  Future<ReportModel> forwardReport({
    required String originalReportId,
    required ReportModel original,
    required String supervisorId,
    required String forwarderNotes,
    required List<String> adminUserIds,
  });

  // Real-time
  Stream<List<ReportModel>> watchReceivedReports(String userId);
  Stream<int> watchUnreadCount(String userId);
}
