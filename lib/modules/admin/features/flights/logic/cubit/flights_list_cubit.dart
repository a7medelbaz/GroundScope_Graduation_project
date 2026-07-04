import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:ground_scope/core/shared/data/repo/flight_repo.dart';
import 'package:ground_scope/core/utils/flight_status_checker.dart';

part 'flights_list_state.dart';

class FlightsListCubit extends Cubit<FlightsListState> {
  FlightsListCubit(this._repo) : super(const FlightsListState());

  final FlightRepo _repo;

  Future<void> load() async {
    emit(state.copyWith(status: FlightsListStatus.loading));
    try {
      // 1. Fetch all flights
      final flights = await _repo.fetchAllFlights();
      debugPrint('FLIGHTS LOAD: Fetched ${flights.length} flights');

      // 2. Auto-update statuses silently (best-effort, won't block UI)
      await _runAutoStatusUpdates(flights);

      // 3. Re-fetch to get updated statuses
      final updated = await _repo.fetchAllFlights();
      debugPrint('FLIGHTS LOAD: After status update: ${updated.length} flights');

      // 4. Sort
      final sorted = [...updated]..sort(FlightStatusChecker.sortFlights);
      debugPrint('FLIGHTS LOAD: After sort: ${sorted.length} flights');

      // 5. Warning flights
      final warnings = sorted.where(FlightStatusChecker.isWarning).toList();
      debugPrint('FLIGHTS LOAD: Warning flights: ${warnings.length}');

      emit(state.copyWith(
        status: FlightsListStatus.success,
        all: sorted,
        filtered: _buildFiltered(sorted, state.filter, state.searchQuery),
        warningFlights: warnings,
      ));
      debugPrint('FLIGHTS LOAD: State emitted with ${sorted.length} flights, filtered: ${state.filtered.length}');
    } on AppError catch (e) {
      debugPrint('FLIGHTS LOAD ERROR: $e');
      emit(state.copyWith(status: FlightsListStatus.failure, error: e));
    } catch (e) {
      debugPrint('FLIGHTS LOAD ERROR: $e');
      emit(state.copyWith(
        status: FlightsListStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }

  /// Silent best-effort auto-status updates. Never throws.
  Future<void> _runAutoStatusUpdates(List<FlightModel> flights) async {
    try {
      final updates = FlightStatusChecker.checkAutoUpdates(flights);
      for (final entry in updates.entries) {
        await _repo.batchUpdateStatus(
          flightIds: entry.value,
          newStatus: entry.key,
        );
      }
    } catch (e) {
      debugPrint('Auto-status update failed: $e');
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filtered: _buildFiltered(state.all, state.filter, query),
    ));
  }

  void onFilterChanged(FlightsFilter filter) {
    emit(state.copyWith(
      filter: filter,
      filtered: _buildFiltered(state.all, filter, state.searchQuery),
    ));
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

  bool isWarning(FlightModel f) => FlightStatusChecker.isWarning(f);

  Future<void> _refreshFlight(String flightId) async {
    try {
      final updated = await _repo.fetchFlightData(flightId: flightId);
      final updatedAll = state.all
          .map((f) => f.id == flightId ? updated : f)
          .toList();
      emit(state.copyWith(
        all: updatedAll,
        filtered: _buildFiltered(updatedAll, state.filter, state.searchQuery),
        warningFlights: updatedAll.where(isWarning).toList(),
      ));
    } catch (_) {
      await load();
    }
  }

  List<FlightModel> _buildFiltered(
    List<FlightModel> flights,
    FlightsFilter filter,
    String query,
  ) {
    var result = switch (filter) {
      FlightsFilter.all        => flights,
      FlightsFilter.active     => flights.where((f) =>
          f.status == FlightStatus.landed ||
          f.status == FlightStatus.inService).toList(),
      FlightsFilter.scheduled  => flights
          .where((f) => f.status == FlightStatus.scheduled).toList(),
      FlightsFilter.ready      => flights
          .where((f) => f.status == FlightStatus.ready).toList(),
      FlightsFilter.departed   => flights
          .where((f) => f.status == FlightStatus.departed).toList(),
      FlightsFilter.arrivals   => flights
          .where((f) => f.flightType == FlightType.arrival).toList(),
      FlightsFilter.departures => flights
          .where((f) => f.flightType == FlightType.departure).toList(),
      FlightsFilter.cancelled  => flights
          .where((f) => f.status == FlightStatus.cancelled).toList(),
    };

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((f) =>
        f.flightNumber.toLowerCase().contains(q) ||
        f.airline.toLowerCase().contains(q) ||
        f.origin.toLowerCase().contains(q) ||
        f.destination.toLowerCase().contains(q),
      ).toList();
    }

    return result;
  }
}
