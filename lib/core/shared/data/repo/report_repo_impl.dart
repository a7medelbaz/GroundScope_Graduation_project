import 'dart:io';
import '../../../../core/shared/data/models/report_model.dart';
import '../remote/report_remote_ds.dart';
import 'report_repo.dart';

class ReportRepoImpl implements ReportRepo {
  ReportRepoImpl({required this.reportRemoteDs});
  final ReportRemoteDs reportRemoteDs;

  @override
  Future<ReportModel> submitReport({
    required String userId,
    required String taskId,
    required String flightId,

    required ReportType type,
    required String description,
    required ReportSeverity severity,
    File? imageFile,
  }) => reportRemoteDs.submitReport(
    userId: userId,
    taskId: taskId,
    flightId: flightId,
    type: type,
    description: description,
    severity: severity,
    imageFile: imageFile,
  );

  @override
  Future<List<ReportModel>> getReportsByTask(String taskId) =>
      reportRemoteDs.getReportsByTask(taskId);

  @override
  Future<List<ReportModel>> getMyReports(String userId) =>
      reportRemoteDs.getMyReports(userId);
}
