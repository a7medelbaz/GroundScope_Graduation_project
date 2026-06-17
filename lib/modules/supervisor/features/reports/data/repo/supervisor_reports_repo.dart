import 'package:ground_scope/core/shared/data/models/report_model.dart';

abstract class SupervisorReportsRepo {
  Future<List<ReportModel>> fetchReports(String serviceTypeId);
  Future<void> acknowledgeReport({required String reportId, required String supervisorId});
  Future<void> resolveReport({required String reportId, required String supervisorId});
}
