import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/shared/data/repo/unit_member_repo.dart';

part 'unit_member_state.dart';

class UnitMemberCubit extends Cubit<UnitMemberState> {
  UnitMemberCubit(this._repo) : super(const UnitMemberState());

  final UnitMemberRepo _repo;

  void initForEdit(UnitMemberModel member) {
    emit(state.copyWith(editing: member));
  }

  Future<bool> submit({
    required String unitId,
    required String fullName,
    required String position,
    String? phone,
    String? nationalId,
  }) async {
    emit(state.copyWith(status: UnitMemberFormStatus.submitting));
    try {
      if (state.isEditMode) {
        await _repo.update(
          state.editing!.copyWith(
            fullName: fullName,
            position: position,
            phone: phone,
            nationalId: nationalId,
          ),
        );
      } else {
        await _repo.create(
          UnitMemberModel(
            id: '',
            unitId: unitId,
            fullName: fullName,
            position: position,
            phone: phone,
            nationalId: nationalId,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
      }
      emit(state.copyWith(status: UnitMemberFormStatus.success));
      return true;
    } on AppError catch (e) {
      emit(state.copyWith(status: UnitMemberFormStatus.failure, error: e));
      return false;
    } catch (_) {
      emit(state.copyWith(
          status: UnitMemberFormStatus.failure, error: AppError.unknown()));
      return false;
    }
  }
}
