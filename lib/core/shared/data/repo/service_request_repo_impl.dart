import 'package:ground_scope/core/shared/data/models/service_request_model.dart';
import 'package:ground_scope/core/shared/data/remote/service_request_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/service_request_repo.dart';

class ServiceRequestRepoImpl implements ServiceRequestRepo {
  const ServiceRequestRepoImpl(this._ds);

  final ServiceRequestRemoteDs _ds;

  @override
  Future<List<AdminServiceRequestModel>> fetchForFlight(String flightId) =>
      _ds.fetchForFlight(flightId);

  @override
  Future<AdminServiceRequestModel> create({
    required String flightId,
    required String serviceTypeId,
    required String requestedBy,
    String? notes,
  }) =>
      _ds.create(
        flightId:      flightId,
        serviceTypeId: serviceTypeId,
        requestedBy:   requestedBy,
        notes:         notes,
      );

  @override
  Future<void> cancel(String requestId) => _ds.cancel(requestId);

  @override
  Future<Map<String, int>> fetchStatusSummary() => _ds.fetchStatusSummary();

  @override
  Stream<List<AdminServiceRequestModel>> watchForFlight(String flightId) =>
      _ds.watchForFlight(flightId);
}
