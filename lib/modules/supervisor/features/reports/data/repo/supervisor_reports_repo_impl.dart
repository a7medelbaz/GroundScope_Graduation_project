import 'package:ground_scope/core/shared/data/models/report_model.dart';
import '../remote/supervisor_reports_remote_ds.dart';
import 'supervisor_reports_repo.dart';

class SupervisorReportsRepoImpl implements SupervisorReportsRepo {
  const SupervisorReportsRepoImpl(this._remoteDs);

  final SupervisorReportsRemoteDs _remoteDs;

  @override
  Future<List<ReportModel>> fetchReports(String serviceTypeId) =>
      _remoteDs.fetchReports(serviceTypeId);

  @override
  Future<void> acknowledgeReport({required String reportId, required String supervisorId}) =>
      _remoteDs.acknowledgeReport(reportId: reportId, supervisorId: supervisorId);

  @override
  Future<void> resolveReport({required String reportId, required String supervisorId}) =>
      _remoteDs.resolveReport(reportId: reportId, supervisorId: supervisorId);
}
