import 'dart:io';
import 'package:ground_scope/core/shared/data/models/report_model.dart';

abstract class SupervisorReportsRepo {
  Future<List<ReportModel>> fetchInbox(String supervisorId);
  Future<List<ReportModel>> fetchSent(String supervisorId);
  Future<List<ReportModel>> fetchFromAdmin(String supervisorId);

  Future<ReportModel> sendToUnit({
    required String supervisorId,
    required String unitId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  });

  Future<ReportModel> broadcast({
    required String supervisorId,
    required String serviceTypeId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  });

  Future<ReportModel> forwardToAdmin({
    required ReportModel original,
    required String supervisorId,
    required String notes,
  });

  Future<void> acknowledgeReport({
      required String reportId, required String supervisorId});
  Future<void> resolveReport({
      required String reportId, required String supervisorId});
}
