import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/generated_credentials.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo.dart';
import 'package:ground_scope/core/shared/data/repo/unit_repo.dart';
import 'package:ground_scope/core/shared/data/repo/user_repo.dart';
import 'package:ground_scope/core/utils/credentials_generator.dart';

part 'unit_form_state.dart';

class UnitFormCubit extends Cubit<UnitFormState> {
  UnitFormCubit(this._unitRepo, this._serviceTypeRepo, this._userRepo)
      : super(const UnitFormState());

  final UnitRepo _unitRepo;
  final ServiceTypeRepo _serviceTypeRepo;
  final UserRepo _userRepo;

  Future<void> init() async {
    try {
      final serviceTypes = await _serviceTypeRepo.fetchAll(isActive: true);
      if (isClosed) return;
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
        if (isClosed) return true;
        emit(state.copyWith(status: UnitFormStatus.success));
        return true;
      } else {
        final created = await _unitRepo.create(
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

        // Auto-create unit manager account for the new unit
        final email = CredentialsGenerator.unitManagerEmail(name);
        final password = CredentialsGenerator.generatePassword();
        final fullName = '$name Manager';

        try {
          await _userRepo.createAccount(
            fullName: fullName,
            email: email,
            password: password,
            role: UserRole.unitManager,
            unitId: created.id,
          );
          if (isClosed) return true;
          emit(state.copyWith(
            status: UnitFormStatus.success,
            generatedCredentials: GeneratedCredentials(
              email: email,
              password: password,
              fullName: fullName,
              role: UserRole.unitManager,
              unitName: name,
            ),
          ));
        } catch (_) {
          // Account creation failed — unit still created successfully
          if (isClosed) return true;
          emit(state.copyWith(
            status: UnitFormStatus.success,
            credentialsError: true,
          ));
        }

        return true;
      }
    } on AppError catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(status: UnitFormStatus.failure, error: e));
      return false;
    } catch (_) {
      if (isClosed) return false;
      emit(state.copyWith(
          status: UnitFormStatus.failure, error: AppError.unknown()));
      return false;
    }
  }
}
