import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/generated_credentials.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo.dart';
import 'package:ground_scope/core/shared/data/repo/user_repo.dart';
import 'package:ground_scope/core/utils/credentials_generator.dart';

part 'service_type_form_state.dart';

class ServiceTypeFormCubit extends Cubit<ServiceTypeFormState> {
  ServiceTypeFormCubit(this._repo, this._userRepo)
      : super(const ServiceTypeFormState());

  final ServiceTypeRepo _repo;
  final UserRepo _userRepo;

  void initForEdit(ServiceTypeModel model) {
    emit(state.copyWith(editing: model));
  }

  Future<bool> submit({
    required String name,
    required String? description,
    required int durationMinutes,
    required String? icon,
    required bool isActive,
  }) async {
    emit(state.copyWith(status: ServiceTypeFormStatus.submitting));
    try {
      if (state.isEditMode) {
        await _repo.update(
          state.editing!.copyWith(
            name: name,
            description: description,
            defaultDurationMinutes: durationMinutes,
            icon: icon,
            isActive: isActive,
          ),
        );
        emit(state.copyWith(status: ServiceTypeFormStatus.success));
        return true;
      } else {
        final created = await _repo.create(
          ServiceTypeModel(
            id: '',
            name: name,
            description: description,
            defaultDurationMinutes: durationMinutes,
            icon: icon,
            isActive: isActive,
          ),
        );

        // Auto-create supervisor account for the new service type
        final email = CredentialsGenerator.supervisorEmail(name);
        final password = CredentialsGenerator.generatePassword();
        final fullName = '$name Supervisor';

        try {
          await _userRepo.createAccount(
            fullName: fullName,
            email: email,
            password: password,
            role: UserRole.supervisor,
            serviceTypeId: created.id,
          );
          emit(state.copyWith(
            status: ServiceTypeFormStatus.success,
            generatedCredentials: GeneratedCredentials(
              email: email,
              password: password,
              fullName: fullName,
              role: UserRole.supervisor,
              serviceTypeName: name,
            ),
          ));
        } catch (_) {
          // Account creation failed — service type still created successfully
          emit(state.copyWith(
            status: ServiceTypeFormStatus.success,
            credentialsError: true,
          ));
        }

        return true;
      }
    } on AppError catch (e) {
      emit(state.copyWith(status: ServiceTypeFormStatus.failure, error: e));
      return false;
    } catch (_) {
      emit(state.copyWith(
        status: ServiceTypeFormStatus.failure,
        error: AppError.unknown(),
      ));
      return false;
    }
  }
}
