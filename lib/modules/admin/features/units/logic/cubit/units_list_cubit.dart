import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/shared/data/repo/unit_repo.dart';

part 'units_list_state.dart';

class UnitsListCubit extends Cubit<UnitsListState> {
  UnitsListCubit(this._repo) : super(const UnitsListState());

  final UnitRepo _repo;

  Future<void> load() async {
    emit(state.copyWith(status: UnitsListStatus.loading));
    try {
      final all = await _repo.fetchAll();
      emit(state.copyWith(status: UnitsListStatus.success, all: all));
      _applyFilters();
    } on AppError catch (e) {
      emit(state.copyWith(status: UnitsListStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
          status: UnitsListStatus.failure, error: AppError.unknown()));
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void onFilterChanged(UnitsFilter filter) {
    emit(state.copyWith(filter: filter));
    _applyFilters();
  }

  Future<void> updateUnitStatus(UnitModel unit, UnitStatus status) async {
    try {
      await _repo.updateStatus(unit.id, status);
      final updatedAll = state.all.map((u) {
        return u.id == unit.id ? u.copyWith(status: status.value) : u;
      }).toList();
      emit(state.copyWith(all: updatedAll));
      _applyFilters();
    } on AppError catch (e) {
      emit(state.copyWith(error: e));
    } catch (_) {
      emit(state.copyWith(error: AppError.unknown()));
    }
  }

  void _applyFilters() {
    var list = state.all;

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      list = list.where((u) {
        return u.name.toLowerCase().contains(q) ||
            (u.serviceTypeName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    switch (state.filter) {
      case UnitsFilter.available:
        list = list.where((u) => u.status == 'available').toList();
      case UnitsFilter.busy:
        list = list.where((u) => u.status == 'busy').toList();
      case UnitsFilter.offline:
        list = list.where((u) => u.status == 'offline').toList();
      case UnitsFilter.maintenance:
        list = list.where((u) => u.status == 'maintenance').toList();
      case UnitsFilter.all:
        break;
    }

    emit(state.copyWith(filtered: list));
  }
}
