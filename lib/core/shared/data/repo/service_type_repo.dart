import 'package:ground_scope/core/shared/data/models/service_type_model.dart';

abstract class ServiceTypeRepo {
  Future<List<ServiceTypeModel>> fetchAll({bool? isActive});
  Future<ServiceTypeModel> fetchById(String id);
  Future<ServiceTypeModel> create(ServiceTypeModel model);
  Future<ServiceTypeModel> update(ServiceTypeModel model);
  Future<void> setActive(String id, bool isActive);
  Future<int> countUnitsUsingServiceType(String serviceTypeId);
  Future<int> countActiveTasksUsingServiceType(String serviceTypeId);
}
