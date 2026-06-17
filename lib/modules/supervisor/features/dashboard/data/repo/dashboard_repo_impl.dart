import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import '../models/service_request_model.dart';
import '../remote/dashboard_remote_ds.dart';
import 'dashboard_repo.dart';

class DashboardRepoImpl implements DashboardRepo {
  const DashboardRepoImpl(this._remoteDs);

  final DashboardRemoteDs _remoteDs;

  @override
  Future<Map<String, int>> fetchTaskStats(String serviceTypeId) =>
      _remoteDs.fetchTaskStats(serviceTypeId);

  @override
  Future<Map<String, int>> fetchUnitStats(String serviceTypeId) =>
      _remoteDs.fetchUnitStats(serviceTypeId);

  @override
  Future<int> fetchOpenReportCount(String serviceTypeId) =>
      _remoteDs.fetchOpenReportCount(serviceTypeId);

  @override
  Future<List<ServiceRequestModel>> fetchPendingServiceRequests(
          String serviceTypeId) =>
      _remoteDs.fetchPendingServiceRequests(serviceTypeId);

  @override
  Future<List<UnitModel>> fetchUnitsPreview(String serviceTypeId,
          {int limit = 3}) =>
      _remoteDs.fetchUnitsPreview(serviceTypeId, limit: limit);

  @override
  Future<String?> fetchServiceTypeName(String serviceTypeId) =>
      _remoteDs.fetchServiceTypeName(serviceTypeId);
}
