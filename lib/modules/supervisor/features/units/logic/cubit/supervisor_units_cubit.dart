import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import '../../data/repo/supervisor_units_repo.dart';

part 'supervisor_units_state.dart';

class SupervisorUnitsCubit extends Cubit<SupervisorUnitsState> {
  SupervisorUnitsCubit({required SupervisorUnitsRepo repo})
      : _repo = repo,
        super(const SupervisorUnitsState());

  final SupervisorUnitsRepo _repo;
  StreamSubscription<List<UnitModel>>? _subscription;

  Future<void> loadUnits(String serviceTypeId) async {
    emit(state.copyWith(status: SupervisorUnitsStatus.loading));
    try {
      // 1. Initial fetch — includes unit_members via join
      final units = await _repo.getUnits(serviceTypeId);
      emit(state.copyWith(
        status: SupervisorUnitsStatus.loaded,
        allUnits: units,
        filteredUnits: _applyFilters(units, state.activeFilter, state.searchQuery),
      ));

      // 2. Realtime subscription — stream gives status updates only (no members join).
      //    Merge incoming units with existing member data to preserve the initial fetch.
      await _subscription?.cancel();
      _subscription = _repo.watchUnits(serviceTypeId).listen(
        (updated) {
          final merged = updated.map((u) {
            final existing = state.allUnits.firstWhere(
              (e) => e.id == u.id,
              orElse: () => u,
            );
            return u.copyWith(members: existing.members);
          }).toList();
          // Keep alphabetical order consistent with the initial fetch
          merged.sort((a, b) => a.name.compareTo(b.name));
          emit(state.copyWith(
            allUnits: merged,
            filteredUnits:
                _applyFilters(merged, state.activeFilter, state.searchQuery),
          ));
        },
        onError: (e) => debugPrint('SupervisorUnitsCubit stream error: $e'),
      );
    } on AppError catch (e) {
      emit(state.copyWith(status: SupervisorUnitsStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('SupervisorUnitsCubit.loadUnits error: $e\n$st');
      emit(state.copyWith(
          status: SupervisorUnitsStatus.failure, error: AppError.unknown()));
    }
  }

  void setFilter(String filter) {
    final filtered = _applyFilters(state.allUnits, filter, state.searchQuery);
    emit(state.copyWith(activeFilter: filter, filteredUnits: filtered));
  }

  void setSearch(String query) {
    final filtered = _applyFilters(state.allUnits, state.activeFilter, query);
    emit(state.copyWith(searchQuery: query, filteredUnits: filtered));
  }

  List<UnitModel> _applyFilters(
    List<UnitModel> all,
    String filter,
    String query,
  ) {
    return all.where((u) {
      final matchesFilter = filter == 'all' || u.status == filter;
      final matchesSearch = query.isEmpty ||
          u.name.toLowerCase().contains(query.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
