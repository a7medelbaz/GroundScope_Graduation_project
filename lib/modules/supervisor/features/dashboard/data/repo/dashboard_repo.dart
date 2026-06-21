import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import '../models/service_request_model.dart';

abstract class DashboardRepo {
  Future<Map<String, int>> fetchTaskStats(String serviceTypeId);
  Future<Map<String, int>> fetchUnitStats(String serviceTypeId);
  Future<int> fetchOpenReportCount(String serviceTypeId);
  Future<List<ServiceRequestModel>> fetchPendingServiceRequests(
      String serviceTypeId);
  Future<List<UnitModel>> fetchUnitsPreview(String serviceTypeId,
      {int limit = 3});
  Future<String?> fetchServiceTypeName(String serviceTypeId);
  Stream<List<ServiceRequestModel>> watchPendingServiceRequests(
      String serviceTypeId);
}
