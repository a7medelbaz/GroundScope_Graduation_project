import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo.dart';
import 'package:ground_scope/modules/admin/features/service_types/data/models/service_type_usage_model.dart';

part 'service_types_list_state.dart';

class ServiceTypesListCubit extends Cubit<ServiceTypesListState> {
  ServiceTypesListCubit(this._repo) : super(const ServiceTypesListState());

  final ServiceTypeRepo _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ServiceTypesListStatus.loading));
    try {
      final all = await _repo.fetchAll();
      final newState = state.copyWith(
        status: ServiceTypesListStatus.success,
        all: all,
      );
      emit(newState);
      _applyFilters();
    } on AppError catch (e) {
      emit(state.copyWith(status: ServiceTypesListStatus.failure, error: e));
    } catch (_) {
      emit(
        state.copyWith(
          status: ServiceTypesListStatus.failure,
          error: AppError.unknown(),
        ),
      );
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void onFilterChanged(ServiceTypesFilter filter) {
    emit(state.copyWith(filter: filter));
    _applyFilters();
  }

  Future<void> toggleActive(ServiceTypeModel model) async {
    try {
      final newIsActive = !model.isActive;
      await _repo.setActive(model.id, newIsActive);
      final updatedAll = state.all.map((item) {
        return item.id == model.id
            ? item.copyWith(isActive: newIsActive)
            : item;
      }).toList();
      emit(state.copyWith(all: updatedAll));
      _applyFilters();
    } on AppError catch (e) {
      emit(state.copyWith(error: e));
    } catch (_) {
      emit(state.copyWith(error: AppError.unknown()));
    }
  }

  Future<ServiceTypeUsageModel> getUsage(String id) async {
    final results = await Future.wait([
      _repo.countUnitsUsingServiceType(id),
      _repo.countActiveTasksUsingServiceType(id),
    ]);
    return ServiceTypeUsageModel(
      unitsCount: results[0],
      activeTasksCount: results[1],
    );
  }

  void _applyFilters() {
    var list = state.all;

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      list = list.where((m) => m.name.toLowerCase().contains(q)).toList();
    }

    switch (state.filter) {
      case ServiceTypesFilter.active:
        list = list.where((m) => m.isActive).toList();
      case ServiceTypesFilter.inactive:
        list = list.where((m) => !m.isActive).toList();
      case ServiceTypesFilter.all:
        break;
    }

    emit(state.copyWith(filtered: list));
  }
}
