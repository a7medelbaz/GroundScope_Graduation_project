import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/shared/data/repo/unit_member_repo.dart';
import 'package:ground_scope/core/shared/data/repo/unit_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._unitRepo, this._unitMemberRepo) : super(const ProfileState());

  final UnitRepo _unitRepo;
  final UnitMemberRepo _unitMemberRepo;

  Future<void> loadProfile({required String unitId}) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final results = await Future.wait([
        _unitRepo.fetchUnitById(unitId),
        _unitMemberRepo.fetchUnitMembers(unitId),
      ]);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          unit: results[0] as UnitProfileModel,
          members: results[1] as List<UnitMemberModel>,
        ),
      );
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: ProfileStatus.failure, error: e));
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          error: AppError.unknown(),
        ),
      );
    }
  }
}
