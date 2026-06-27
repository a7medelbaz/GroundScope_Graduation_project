import 'dart:io';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import '../remote/supervisor_reports_remote_ds.dart';
import 'supervisor_reports_repo.dart';

class SupervisorReportsRepoImpl implements SupervisorReportsRepo {
  const SupervisorReportsRepoImpl(this._remoteDs);

  final SupervisorReportsRemoteDs _remoteDs;

  @override
  Future<List<ReportModel>> fetchInbox(String supervisorId) =>
      _remoteDs.fetchInbox(supervisorId);

  @override
  Future<List<ReportModel>> fetchSent(String supervisorId) =>
      _remoteDs.fetchSent(supervisorId);

  @override
  Future<List<ReportModel>> fetchFromAdmin(String supervisorId) =>
      _remoteDs.fetchFromAdmin(supervisorId);

  @override
  Future<ReportModel> sendToUnit({
    required String supervisorId,
    required String unitId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) =>
      _remoteDs.sendToUnit(
        supervisorId: supervisorId,
        unitId: unitId,
        type: type,
        severity: severity,
        description: description,
        imageFile: imageFile,
      );

  @override
  Future<ReportModel> broadcast({
    required String supervisorId,
    required String serviceTypeId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) =>
      _remoteDs.broadcast(
        supervisorId: supervisorId,
        serviceTypeId: serviceTypeId,
        type: type,
        severity: severity,
        description: description,
        imageFile: imageFile,
      );

  @override
  Future<ReportModel> forwardToAdmin({
    required ReportModel original,
    required String supervisorId,
    required String notes,
  }) =>
      _remoteDs.forwardToAdmin(
          original: original, supervisorId: supervisorId, notes: notes);

  @override
  Future<void> acknowledgeReport(
          {required String reportId, required String supervisorId}) =>
      _remoteDs.acknowledgeReport(
          reportId: reportId, supervisorId: supervisorId);

  @override
  Future<void> resolveReport(
          {required String reportId, required String supervisorId}) =>
      _remoteDs.resolveReport(reportId: reportId, supervisorId: supervisorId);
}
