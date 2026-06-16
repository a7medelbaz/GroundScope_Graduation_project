import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:ground_scope/core/shared/data/repo/flight_repo.dart';

part 'flights_list_state.dart';

class FlightsListCubit extends Cubit<FlightsListState> {
  FlightsListCubit(this._repo) : super(const FlightsListState());

  final FlightRepo _repo;

  Future<void> load() async {
    emit(state.copyWith(status: FlightsListStatus.loading));
    try {
      final results = await Future.wait([
        _repo.fetchFlights(),
        _repo.fetchFlightsNeedingAttention(),
      ]);
      emit(
        state.copyWith(
          status: FlightsListStatus.success,
          all: results[0],
          warningFlights: results[1],
        ),
      );
      _applyFilters();
    } on AppError catch (e) {
      emit(state.copyWith(status: FlightsListStatus.failure, error: e));
    } catch (_) {
      emit(
        state.copyWith(
          status: FlightsListStatus.failure,
          error: AppError.unknown(),
        ),
      );
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void onFilterChanged(FlightsFilter filter) {
    emit(state.copyWith(filter: filter));
    _applyFilters();
  }

  /// Returns true if assignment succeeded.
  /// Returns false if user confirmation is needed due to an aircraft
  /// incompatibility — the UI should watch [FlightsListState.pendingAssignment]
  /// and call [confirmAssignStand] or [cancelPendingAssignment].
  Future<bool> assignStand({
    required FlightModel flight,
    required StandModel stand,
  }) async {
    if (!stand.isCompatibleWith(flight.aircraftType)) {
      emit(
        state.copyWith(
          pendingAssignment: PendingStandAssignment(
            flight: flight,
            stand: stand,
            incompatibleAircraft: flight.aircraftType,
          ),
        ),
      );
      return false; // UI handles the confirmation dialog
    }

    return _doAssignStand(flight: flight, stand: stand);
  }

  /// Called after user confirms the incompatibility warning.
  Future<bool> confirmAssignStand() async {
    final pending = state.pendingAssignment;
    if (pending == null) return false;

    emit(state.copyWith(clearPendingAssignment: true));
    return _doAssignStand(flight: pending.flight, stand: pending.stand);
  }

  /// Cancel pending assignment (user dismissed the dialog).
  void cancelPendingAssignment() {
    emit(state.copyWith(clearPendingAssignment: true));
  }

  Future<bool> _doAssignStand({
    required FlightModel flight,
    required StandModel stand,
  }) async {
    emit(state.copyWith(assigningStandId: stand.id));
    try {
      await _repo.assignStand(
        flightId: flight.id,
        standId: stand.id,
        scheduledArrival: flight.scheduledArrival,
        scheduledDeparture: flight.scheduledDeparture,
      );
      await _refreshFlight(flight.id);
      return true;
    } on AppError catch (e) {
      emit(state.copyWith(error: e));
      return false;
    } catch (_) {
      emit(state.copyWith(error: AppError.unknown()));
      return false;
    } finally {
      emit(state.copyWith(clearAssigningStandId: true));
    }
  }

  Future<bool> unassignStand(FlightModel flight) async {
    try {
      await _repo.unassignStand(flight.id);
      await _refreshFlight(flight.id);
      return true;
    } on AppError catch (e) {
      emit(state.copyWith(error: e));
      return false;
    } catch (_) {
      emit(state.copyWith(error: AppError.unknown()));
      return false;
    }
  }

  Future<bool> updateStatus(FlightModel flight, FlightStatus status) async {
    try {
      await _repo.updateStatus(flight.id, status);
      await _refreshFlight(flight.id);
      return true;
    } on AppError catch (e) {
      emit(state.copyWith(error: e));
      return false;
    } catch (_) {
      emit(state.copyWith(error: AppError.unknown()));
      return false;
    }
  }

  Future<List<StandModel>> getAvailableStands(FlightModel flight) =>
      _repo.fetchAvailableStands(
        arrivalTime: flight.scheduledArrival,
        departureTime: flight.scheduledDeparture,
        excludeFlightId: flight.id,
      );

  bool isWarning(FlightModel f) {
    final now = DateTime.now();
    return f.standId == null &&
        f.status == FlightStatus.scheduled &&
        f.scheduledArrival.isAfter(now) &&
        f.scheduledArrival.isBefore(now.add(const Duration(hours: 3)));
  }

  Future<void> _refreshFlight(String flightId) async {
    try {
      final updated = await _repo.fetchFlightData(flightId: flightId);
      final updatedAll = state.all
          .map((f) => f.id == flightId ? updated : f)
          .toList();
      emit(
        state.copyWith(
          all: updatedAll,
          warningFlights: updatedAll.where(isWarning).toList(),
        ),
      );
      _applyFilters();
    } catch (_) {
      await load();
    }
  }

  void _applyFilters() {
    var list = state.all;

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      list = list
          .where(
            (f) =>
                f.flightNumber.toLowerCase().contains(q) ||
                f.airline.toLowerCase().contains(q) ||
                f.origin.toLowerCase().contains(q) ||
                f.destination.toLowerCase().contains(q),
          )
          .toList();
    }

    switch (state.filter) {
      case FlightsFilter.arrivals:
        list = list.where((f) => f.flightType == FlightType.arrival).toList();
      case FlightsFilter.departures:
        list = list
            .where((f) => f.flightType == FlightType.departure)
            .toList();
      case FlightsFilter.scheduled:
        list = list.where((f) => f.status == FlightStatus.scheduled).toList();
      case FlightsFilter.active:
        list = list
            .where(
              (f) =>
                  f.status == FlightStatus.landed ||
                  f.status == FlightStatus.inService ||
                  f.status == FlightStatus.ready,
            )
            .toList();
      case FlightsFilter.cancelled:
        list = list.where((f) => f.status == FlightStatus.cancelled).toList();
      case FlightsFilter.all:
        break;
    }

    emit(state.copyWith(filtered: list));
  }
}
