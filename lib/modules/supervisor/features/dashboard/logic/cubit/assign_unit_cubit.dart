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
      if (isClosed) return;
      emit(state.copyWith(
        status: AssignUnitStatus.loaded,
        allUnits: units,
        filteredUnits: units,
        searchQuery: '',
      ));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: AssignUnitStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('AssignUnitCubit.loadAvailableUnits: $e\n$st');
      if (isClosed) return;
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

  Future<void> createTask({
    required ServiceRequestModel request,
    required UnitModel unit,
    required String priority,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required List<String> checklistItems,
    String? notes,
  }) async {
    emit(state.copyWith(status: AssignUnitStatus.assigning));
    try {
      final user = await _userService.getUser();
      final assignedBy = user?.id ?? '';

      await _repo.createTaskFromRequest(
        requestId:      request.id,
        flightId:       request.flightId,
        serviceTypeId:  request.serviceTypeId,
        unitId:         unit.id,
        assignedBy:     assignedBy,
        priority:       priority,
        scheduledStart: scheduledStart,
        scheduledEnd:   scheduledEnd,
        checklistItems: checklistItems,
        notes:          notes,
      );

      if (isClosed) return;
      emit(state.copyWith(status: AssignUnitStatus.success));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: AssignUnitStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('AssignUnitCubit.createTask: $e\n$st');
      if (isClosed) return;
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