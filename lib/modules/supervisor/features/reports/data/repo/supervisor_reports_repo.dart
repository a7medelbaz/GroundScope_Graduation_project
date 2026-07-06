import 'dart:io';
import 'package:ground_scope/core/shared/data/models/report_model.dart';

abstract class SupervisorReportsRepo {
  Future<(List<ReportModel>, List<ReportModel>)> fetchReceived(
      String supervisorId);
  Future<List<ReportModel>> fetchSent(String supervisorId);

  Future<(ReportModel, List<String>)> sendToUnit({
    required String supervisorId,
    required String unitId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  });

  Future<(ReportModel, List<String>)> broadcast({
    required String supervisorId,
    required String serviceTypeId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  });

  Future<(ReportModel, List<String>)> forwardToAdmin({
    required ReportModel original,
    required String supervisorId,
    required String notes,
  });

  Future<void> markAsRead(
      {required String reportId, required String supervisorId});
  Future<void> acknowledgeReport({
      required String reportId, required String supervisorId});
  Future<void> resolveReport({
      required String reportId, required String supervisorId});

  Stream<(List<ReportModel>, List<ReportModel>)> watchReceived(
      String supervisorId);
}
