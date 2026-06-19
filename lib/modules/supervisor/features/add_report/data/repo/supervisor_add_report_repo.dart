import 'dart:io';
import 'package:ground_scope/core/shared/data/models/report_model.dart';

abstract class SupervisorAddReportRepo {
  Future<void> submitReport({
    required String supervisorId,
    required String reportedTo,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  });
}
