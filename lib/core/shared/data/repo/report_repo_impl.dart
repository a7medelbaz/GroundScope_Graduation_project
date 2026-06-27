import 'dart:io';
import '../../../../core/shared/data/models/report_model.dart';
import '../remote/report_remote_ds.dart';
import 'report_repo.dart';

class ReportRepoImpl implements ReportRepo {
  ReportRepoImpl({required this.reportRemoteDs});
  final ReportRemoteDs reportRemoteDs;

  @override
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
  }) =>
      reportRemoteDs.submitReport(
        reportedBy: reportedBy,
        taskId: taskId,
        flightId: flightId,
        type: type,
        description: description,
        severity: severity,
        direction: direction,
        recipientUserIds: recipientUserIds,
        imageFile: imageFile,
        forwardedFromId: forwardedFromId,
        forwarderNotes: forwarderNotes,
      );

  @override
  Future<List<ReportModel>> fetchSentReports(String userId) =>
      reportRemoteDs.fetchSentReports(userId);

  @override
  Future<List<ReportModel>> fetchReceivedReports(String userId) =>
      reportRemoteDs.fetchReceivedReports(userId);

  @override
  Future<List<ReportModel>> fetchAllReports() =>
      reportRemoteDs.fetchAllReports();

  @override
  Future<List<ReportModel>> fetchReportsByDirection(
          ReportDirection direction) =>
      reportRemoteDs.fetchReportsByDirection(direction);

  @override
  Future<List<ReportModel>> getMyReports(String userId) =>
      reportRemoteDs.getMyReports(userId);

  @override
  Future<int> countOpenReports() => reportRemoteDs.countOpenReports();

  @override
  Future<void> markAsRead({
    required String reportId,
    required String userId,
  }) =>
      reportRemoteDs.markAsRead(reportId: reportId, userId: userId);

  @override
  Future<void> acknowledgeReport({
    required String reportId,
    required String userId,
  }) =>
      reportRemoteDs.acknowledgeReport(reportId: reportId, userId: userId);

  @override
  Future<void> resolveReport({
    required String reportId,
    required String userId,
  }) =>
      reportRemoteDs.resolveReport(reportId: reportId, userId: userId);

  @override
  Future<ReportModel> forwardReport({
    required String originalReportId,
    required ReportModel original,
    required String supervisorId,
    required String forwarderNotes,
    required List<String> adminUserIds,
  }) =>
      reportRemoteDs.forwardReport(
        originalReportId: originalReportId,
        original: original,
        supervisorId: supervisorId,
        forwarderNotes: forwarderNotes,
        adminUserIds: adminUserIds,
      );

  @override
  Stream<List<ReportModel>> watchReceivedReports(String userId) =>
      reportRemoteDs.watchReceivedReports(userId);

  @override
  Stream<int> watchUnreadCount(String userId) =>
      reportRemoteDs.watchUnreadCount(userId);
}
