import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/remote/service_type_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo.dart';

class ServiceTypeRepoImpl implements ServiceTypeRepo {
  ServiceTypeRepoImpl({required this.serviceTypeRemoteDs});
  final ServiceTypeRemoteDs serviceTypeRemoteDs;

  @override
  Future<List<ServiceTypeModel>> fetchAll({bool? isActive}) =>
      serviceTypeRemoteDs.fetchAll(isActive: isActive);

  @override
  Future<ServiceTypeModel> fetchById(String id) =>
      serviceTypeRemoteDs.fetchById(id);

  @override
  Future<ServiceTypeModel> create(ServiceTypeModel model) =>
      serviceTypeRemoteDs.create(model);

  @override
  Future<ServiceTypeModel> update(ServiceTypeModel model) =>
      serviceTypeRemoteDs.update(model);

  @override
  Future<void> setActive(String id, bool isActive) =>
      serviceTypeRemoteDs.setActive(id, isActive);

  @override
  Future<int> countUnitsUsingServiceType(String serviceTypeId) =>
      serviceTypeRemoteDs.countUnitsUsingServiceType(serviceTypeId);

  @override
  Future<int> countActiveTasksUsingServiceType(String serviceTypeId) =>
      serviceTypeRemoteDs.countActiveTasksUsingServiceType(serviceTypeId);
}
