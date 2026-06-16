import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/shared/data/repo/unit_repo.dart';

part 'units_list_state.dart';

class UnitsListCubit extends Cubit<UnitsListState> {
  UnitsListCubit({required this.unitRepo}) : super(UnitsListInitial());

  final UnitRepo unitRepo;

  Future<void> loadUnits() async {
    emit(UnitsListLoading());
    try {
      final units = await unitRepo.fetchAllUnits();
      emit(UnitsListLoaded(allUnits: units, filteredUnits: units));
    } on AppError catch (e) {
      emit(UnitsListFailure(error: e));
    } catch (_) {
      emit(UnitsListFailure(error: AppError.unknown()));
    }
  }

  void search(String query) {
    final current = state;
    if (current is! UnitsListLoaded) return;

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? current.allUnits
        : current.allUnits
            .where(
              (u) =>
                  u.name.toLowerCase().contains(q) ||
                  u.serviceTypeName.toLowerCase().contains(q),
            )
            .toList();

    emit(current.copyWith(filteredUnits: filtered, searchQuery: query));
  }
}
