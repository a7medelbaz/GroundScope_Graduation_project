part of 'flights_list_cubit.dart';

enum FlightsFilter { all, arrivals, departures, scheduled, active, cancelled }

enum FlightsListStatus { initial, loading, success, failure }

class FlightsListState extends Equatable {
  const FlightsListState({
    this.status = FlightsListStatus.initial,
    this.all = const [],
    this.filtered = const [],
    this.warningFlights = const [],
    this.searchQuery = '',
    this.filter = FlightsFilter.all,
    this.error,
  });

  final FlightsListStatus status;
  final List<FlightModel> all;
  final List<FlightModel> filtered;
  final List<FlightModel> warningFlights;
  final String searchQuery;
  final FlightsFilter filter;
  final AppError? error;

  FlightsListState copyWith({
    FlightsListStatus? status,
    List<FlightModel>? all,
    List<FlightModel>? filtered,
    List<FlightModel>? warningFlights,
    String? searchQuery,
    FlightsFilter? filter,
    AppError? error,
  }) {
    return FlightsListState(
      status: status ?? this.status,
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      warningFlights: warningFlights ?? this.warningFlights,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, all, filtered, warningFlights, searchQuery, filter, error];
}
