part of 'assign_unit_cubit.dart';

enum AssignUnitStatus { initial, loading, loaded, assigning, success, failure }

final class AssignUnitState extends Equatable {
  const AssignUnitState({
    this.status = AssignUnitStatus.initial,
    this.allUnits = const [],
    this.filteredUnits = const [],
    this.searchQuery = '',
    this.error,
  });

  final AssignUnitStatus status;
  final List<UnitModel> allUnits;
  final List<UnitModel> filteredUnits;
  final String searchQuery;
  final AppError? error;

  int get resultCount => filteredUnits.length;

  AssignUnitState copyWith({
    AssignUnitStatus? status,
    List<UnitModel>? allUnits,
    List<UnitModel>? filteredUnits,
    String? searchQuery,
    AppError? error,
  }) {
    return AssignUnitState(
      status: status ?? this.status,
      allUnits: allUnits ?? this.allUnits,
      filteredUnits: filteredUnits ?? this.filteredUnits,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, allUnits, filteredUnits, searchQuery, error];
}