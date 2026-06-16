import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/remote/aviation_stack_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/flight_repo.dart';

part 'flight_import_state.dart';

class FlightImportCubit extends Cubit<FlightImportState> {
  FlightImportCubit(this._aviationDs, this._repo)
    : super(const FlightImportState());

  final AviationStackRemoteDs _aviationDs;
  final FlightRepo _repo;

  /// Step 1: Fetch from AviationStack and show preview
  Future<void> fetchPreview() async {
    emit(state.copyWith(status: FlightImportStatus.fetching));
    try {
      final flights = await _aviationDs.fetchTodaysFlights();
      emit(
        state.copyWith(
          status: FlightImportStatus.preview,
          preview: flights,
          selectedIds: _externalIds(flights),
        ),
      );
    } on AppError catch (e) {
      emit(state.copyWith(status: FlightImportStatus.failure, error: e));
    } catch (_) {
      emit(
        state.copyWith(
          status: FlightImportStatus.failure,
          error: AppError.unknown(),
        ),
      );
    }
  }

  /// Step 2: Toggle selection of individual flights
  void toggleSelection(String externalId) {
    final selected = Set<String>.from(state.selectedIds);
    if (!selected.remove(externalId)) {
      selected.add(externalId);
    }
    emit(state.copyWith(selectedIds: selected));
  }

  /// Step 3: Toggle all
  void toggleSelectAll() {
    emit(
      state.copyWith(
        selectedIds: state.allSelected ? {} : _externalIds(state.preview),
      ),
    );
  }

  /// Step 4: Import selected flights to DB
  Future<bool> importSelected() async {
    emit(state.copyWith(status: FlightImportStatus.importing));
    try {
      final toImport = state.preview
          .where((f) => state.selectedIds.contains(f.externalId))
          .toList();
      await _repo.importFlights(toImport);
      emit(
        state.copyWith(
          status: FlightImportStatus.success,
          importedCount: toImport.length,
        ),
      );
      return true;
    } on AppError catch (e) {
      emit(state.copyWith(status: FlightImportStatus.failure, error: e));
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: FlightImportStatus.failure,
          error: AppError.unknown(),
        ),
      );
      return false;
    }
  }

  Set<String> _externalIds(List<FlightModel> flights) => flights
      .map((f) => f.externalId ?? '')
      .where((id) => id.isNotEmpty)
      .toSet();
}
