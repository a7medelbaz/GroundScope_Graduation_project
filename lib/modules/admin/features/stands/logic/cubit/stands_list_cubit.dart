import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:ground_scope/core/shared/data/repo/stand_repo.dart';

part 'stands_list_state.dart';

class StandsListCubit extends Cubit<StandsListState> {
  StandsListCubit(this._repo) : super(const StandsListState());

  final StandRepo _repo;

  Future<void> load() async {
    emit(state.copyWith(status: StandsListStatus.loading));
    try {
      final all = await _repo.fetchAll();
      emit(state.copyWith(status: StandsListStatus.success, all: all));
      _applyFilters();
    } on AppError catch (e) {
      emit(state.copyWith(status: StandsListStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
          status: StandsListStatus.failure, error: AppError.unknown()));
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void onFilterChanged(StandsFilter filter) {
    emit(state.copyWith(filter: filter));
    _applyFilters();
  }

  Future<void> toggleActive(StandModel model) async {
    try {
      final newIsActive = !model.isActive;
      await _repo.setActive(model.id, newIsActive);
      final updatedAll = state.all.map((item) {
        return item.id == model.id ? item.copyWith(isActive: newIsActive) : item;
      }).toList();
      emit(state.copyWith(all: updatedAll));
      _applyFilters();
    } on AppError catch (e) {
      emit(state.copyWith(error: e));
    } catch (_) {
      emit(state.copyWith(error: AppError.unknown()));
    }
  }

  Future<int> getFlightsCount(String standId) =>
      _repo.countFlightsAtStand(standId);

  void _applyFilters() {
    var list = state.all;

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      list = list
          .where((s) =>
              s.code.toLowerCase().contains(q) ||
              s.terminal.toLowerCase().contains(q))
          .toList();
    }

    switch (state.filter) {
      case StandsFilter.active:
        list = list.where((s) => s.isActive).toList();
      case StandsFilter.inactive:
        list = list.where((s) => !s.isActive).toList();
      case StandsFilter.all:
        break;
    }

    emit(state.copyWith(filtered: list));
  }
}
