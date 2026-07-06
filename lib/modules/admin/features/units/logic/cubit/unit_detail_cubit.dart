import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/shared/data/repo/unit_member_repo.dart';
import 'package:ground_scope/core/shared/data/repo/unit_repo.dart';

part 'unit_detail_state.dart';

class UnitDetailCubit extends Cubit<UnitDetailState> {
  UnitDetailCubit(this._unitRepo, this._memberRepo)
      : super(const UnitDetailState());

  final UnitRepo _unitRepo;
  final UnitMemberRepo _memberRepo;

  Future<void> load(String unitId) async {
    emit(state.copyWith(status: UnitDetailStatus.loading));
    try {
      final results = await Future.wait([
        _unitRepo.fetchUnitModelById(unitId),
        _unitRepo.fetchUnitTasks(unitId),
        _memberRepo.fetchUnitMembers(unitId),
      ]);

      final unit = results[0] as UnitModel?;
      if (unit == null) throw AppError.unknown('Unit not found');

      if (isClosed) return;
      emit(state.copyWith(
        status: UnitDetailStatus.success,
        unit: unit,
        tasks: results[1] as List<TaskModel>,
        members: results[2] as List<UnitMemberModel>,
      ));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: UnitDetailStatus.failure, error: e));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
          status: UnitDetailStatus.failure, error: AppError.unknown()));
    }
  }

  Future<void> refreshTasks(String unitId) async {
    try {
      final tasks = await _unitRepo.fetchUnitTasks(unitId);
      if (isClosed) return;
      emit(state.copyWith(tasks: tasks));
    } catch (_) {}
  }

  Future<void> refreshMembers(String unitId) async {
    try {
      final members = await _memberRepo.fetchUnitMembers(unitId);
      if (isClosed) return;
      emit(state.copyWith(members: members));
    } catch (_) {}
  }

  Future<void> addMember(UnitMemberModel member) async {
    try {
      final created = await _memberRepo.create(member);
      if (isClosed) return;
      emit(state.copyWith(members: [...state.members, created]));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(error: e));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(error: AppError.unknown()));
    }
  }

  Future<void> updateMember(UnitMemberModel member) async {
    try {
      final updated = await _memberRepo.update(member);
      if (isClosed) return;
      final members = state.members
          .map((m) => m.id == updated.id ? updated : m)
          .toList();
      emit(state.copyWith(members: members));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(error: e));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(error: AppError.unknown()));
    }
  }

  Future<void> deactivateMember(String memberId) async {
    try {
      await _memberRepo.deactivate(memberId);
      if (isClosed) return;
      final members = state.members.where((m) => m.id != memberId).toList();
      emit(state.copyWith(members: members));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(error: e));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(error: AppError.unknown()));
    }
  }

  void updateUnitLocally(UnitModel unit) {
    emit(state.copyWith(unit: unit));
  }

  Future<bool> updateStatus(String unitId, UnitStatus status) async {
    try {
      await _unitRepo.updateStatus(unitId, status);
      if (isClosed) return true;
      if (state.unit != null) {
        emit(state.copyWith(unit: state.unit!.copyWith(status: status.value)));
      }
      return true;
    } on AppError catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(error: e));
      return false;
    } catch (_) {
      if (isClosed) return false;
      emit(state.copyWith(error: AppError.unknown()));
      return false;
    }
  }
}
