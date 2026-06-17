part of 'supervisor_units_cubit.dart';

enum SupervisorUnitsStatus { initial, loading, loaded, failure }

final class SupervisorUnitsState extends Equatable {
  const SupervisorUnitsState({
    this.status = SupervisorUnitsStatus.initial,
    this.allUnits = const [],
    this.filteredUnits = const [],
    this.activeFilter = 'all',
    this.searchQuery = '',
    this.error,
  });

  final SupervisorUnitsStatus status;
  final List<UnitModel> allUnits;
  final List<UnitModel> filteredUnits;
  final String activeFilter;
  final String searchQuery;
  final AppError? error;

  int get resultCount => filteredUnits.length;

  SupervisorUnitsState copyWith({
    SupervisorUnitsStatus? status,
    List<UnitModel>? allUnits,
    List<UnitModel>? filteredUnits,
    String? activeFilter,
    String? searchQuery,
    AppError? error,
  }) {
    return SupervisorUnitsState(
      status: status ?? this.status,
      allUnits: allUnits ?? this.allUnits,
      filteredUnits: filteredUnits ?? this.filteredUnits,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, allUnits, filteredUnits, activeFilter, searchQuery, error];
}
