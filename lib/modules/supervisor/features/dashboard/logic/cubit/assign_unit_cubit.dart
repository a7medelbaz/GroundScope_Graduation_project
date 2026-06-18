import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/models/service_request_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/repo/assign_unit_repo.dart';

part 'assign_unit_state.dart';

class AssignUnitCubit extends Cubit<AssignUnitState> {
  AssignUnitCubit({
    required AssignUnitRepo repo,
    required UserService userService,
  })  : _repo = repo,
        _userService = userService,
        super(const AssignUnitState());

  final AssignUnitRepo _repo;
  final UserService _userService;

  Future<void> loadAvailableUnits(String serviceTypeId) async {
    emit(state.copyWith(status: AssignUnitStatus.loading));
    try {
      final units = await _repo.getAvailableUnits(serviceTypeId);
      emit(state.copyWith(
        status: AssignUnitStatus.loaded,
        allUnits: units,
        filteredUnits: units,
        searchQuery: '',
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: AssignUnitStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('AssignUnitCubit.loadAvailableUnits: $e\n$st');
      emit(state.copyWith(
          status: AssignUnitStatus.failure, error: AppError.unknown()));
    }
  }

  void setSearch(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredUnits: _filter(state.allUnits, query),
    ));
  }

  Future<void> assign({
    required ServiceRequestModel request,
    required UnitModel unit,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
  }) async {
    emit(state.copyWith(status: AssignUnitStatus.assigning));
    try {
      final user = await _userService.getUser();
      final assignedBy = user?.id ?? '';

      await _repo.assignUnit(
        requestId:      request.id,
        unitId:         unit.id,
        assignedBy:     assignedBy,
        flightId:       request.flightId,
        serviceTypeId:  request.serviceTypeId,
        scheduledStart: scheduledStart,
        scheduledEnd:   scheduledEnd,
        notes:          request.notes,
      );

      emit(state.copyWith(status: AssignUnitStatus.success));
    } on AppError catch (e) {
      emit(state.copyWith(status: AssignUnitStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('AssignUnitCubit.assign: $e\n$st');
      emit(state.copyWith(
          status: AssignUnitStatus.failure, error: AppError.unknown()));
    }
  }

  List<UnitModel> _filter(List<UnitModel> all, String query) {
    if (query.isEmpty) return all;
    return all
        .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}