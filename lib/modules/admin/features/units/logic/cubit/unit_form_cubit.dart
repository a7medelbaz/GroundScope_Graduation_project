import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo.dart';
import 'package:ground_scope/core/shared/data/repo/unit_repo.dart';

part 'unit_form_state.dart';

class UnitFormCubit extends Cubit<UnitFormState> {
  UnitFormCubit(this._unitRepo, this._serviceTypeRepo)
      : super(const UnitFormState());

  final UnitRepo _unitRepo;
  final ServiceTypeRepo _serviceTypeRepo;

  Future<void> init() async {
    try {
      final serviceTypes = await _serviceTypeRepo.fetchAll(isActive: true);
      emit(state.copyWith(serviceTypes: serviceTypes));
    } catch (_) {}
  }

  void initForEdit(UnitModel model) {
    emit(state.copyWith(editing: model));
  }

  Future<bool> submit({
    required String name,
    required String serviceTypeId,
    required UnitStatus status,
    required List<String> compatibleAircraft,
    required String? shiftStartTime,
    required String? shiftEndTime,
  }) async {
    emit(state.copyWith(status: UnitFormStatus.submitting));
    try {
      if (state.isEditMode) {
        await _unitRepo.update(
          state.editing!.copyWith(
            name: name,
            serviceTypeId: serviceTypeId,
            status: status.value,
            compatibleAircraft: compatibleAircraft,
            shiftStartTime: shiftStartTime,
            shiftEndTime: shiftEndTime,
          ),
        );
      } else {
        await _unitRepo.create(
          UnitModel(
            id: '',
            name: name,
            serviceTypeId: serviceTypeId,
            status: status.value,
            compatibleAircraft: compatibleAircraft,
            shiftStartTime: shiftStartTime,
            shiftEndTime: shiftEndTime,
          ),
        );
      }
      emit(state.copyWith(status: UnitFormStatus.success));
      return true;
    } on AppError catch (e) {
      emit(state.copyWith(status: UnitFormStatus.failure, error: e));
      return false;
    } catch (_) {
      emit(state.copyWith(
          status: UnitFormStatus.failure, error: AppError.unknown()));
      return false;
    }
  }
}
