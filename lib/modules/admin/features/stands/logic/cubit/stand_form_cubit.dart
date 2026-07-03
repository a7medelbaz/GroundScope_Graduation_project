import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:ground_scope/core/shared/data/repo/stand_repo.dart';

part 'stand_form_state.dart';

class StandFormCubit extends Cubit<StandFormState> {
  StandFormCubit(this._repo) : super(const StandFormState());

  final StandRepo _repo;

  void initForEdit(StandModel model) {
    emit(state.copyWith(editing: model));
  }

  Future<bool> submit({
    required String code,
    required String terminal,
    required List<String> compatibleAircraft,
    required bool isActive,
  }) async {
    emit(state.copyWith(status: StandFormStatus.submitting));
    try {
      if (state.isEditMode) {
        await _repo.update(
          state.editing!.copyWith(
            code: code,
            terminal: terminal,
            compatibleAircraft: compatibleAircraft,
            isActive: isActive,
          ),
        );
      } else {
        await _repo.create(
          StandModel(
            id: '',
            code: code,
            terminal: terminal,
            compatibleAircraft: compatibleAircraft,
            hasCamera: false,
            isActive: isActive,
            createdAt: DateTime.now(),
          ),
        );
      }
      if (isClosed) return true;
      emit(state.copyWith(status: StandFormStatus.success));
      return true;
    } on AppError catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(status: StandFormStatus.failure, error: e));
      return false;
    } catch (_) {
      if (isClosed) return false;
      emit(state.copyWith(
          status: StandFormStatus.failure, error: AppError.unknown()));
      return false;
    }
  }
}
