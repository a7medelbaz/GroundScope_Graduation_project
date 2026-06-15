import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo.dart';

part 'service_type_form_state.dart';

class ServiceTypeFormCubit extends Cubit<ServiceTypeFormState> {
  ServiceTypeFormCubit(this._repo) : super(const ServiceTypeFormState());

  final ServiceTypeRepo _repo;

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
      } else {
        await _repo.create(
          ServiceTypeModel(
            id: '',
            name: name,
            description: description,
            defaultDurationMinutes: durationMinutes,
            icon: icon,
            isActive: isActive,
          ),
        );
      }
      emit(state.copyWith(status: ServiceTypeFormStatus.success));
      return true;
    } on AppError catch (e) {
      emit(
        state.copyWith(status: ServiceTypeFormStatus.failure, error: e),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: ServiceTypeFormStatus.failure,
          error: AppError.unknown(),
        ),
      );
      return false;
    }
  }
}
