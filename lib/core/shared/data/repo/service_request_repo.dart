import 'package:ground_scope/core/shared/data/models/service_request_model.dart';

abstract class ServiceRequestRepo {
  Future<List<AdminServiceRequestModel>> fetchForFlight(String flightId);

  Future<AdminServiceRequestModel> create({
    required String flightId,
    required String serviceTypeId,
    required String requestedBy,
    String? notes,
  });

  Future<void> cancel(String requestId);

  Future<Map<String, int>> fetchStatusSummary();
}
