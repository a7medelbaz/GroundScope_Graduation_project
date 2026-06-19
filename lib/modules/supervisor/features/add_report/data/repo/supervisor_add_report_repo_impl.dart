import 'dart:io';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import '../remote/supervisor_add_report_remote_ds.dart';
import 'supervisor_add_report_repo.dart';

class SupervisorAddReportRepoImpl implements SupervisorAddReportRepo {
  const SupervisorAddReportRepoImpl(this._remoteDs);
  final SupervisorAddReportRemoteDs _remoteDs;

  @override
  Future<void> submitReport({
    required String supervisorId,
    required String reportedTo,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) =>
      _remoteDs.submitReport(
        supervisorId: supervisorId,
        reportedTo: reportedTo,
        type: type,
        severity: severity,
        description: description,
        imageFile: imageFile,
      );
}
