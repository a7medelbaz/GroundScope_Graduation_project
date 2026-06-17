part of 'units_list_cubit.dart';

enum UnitsFilter { all, available, busy, offline, maintenance }

enum UnitsListStatus { initial, loading, success, failure }

class UnitsListState extends Equatable {
  const UnitsListState({
    this.status = UnitsListStatus.initial,
    this.all = const [],
    this.filtered = const [],
    this.searchQuery = '',
    this.filter = UnitsFilter.all,
    this.error,
  });

  final UnitsListStatus status;
  final List<UnitModel> all;
  final List<UnitModel> filtered;
  final String searchQuery;
  final UnitsFilter filter;
  final AppError? error;

  UnitsListState copyWith({
    UnitsListStatus? status,
    List<UnitModel>? all,
    List<UnitModel>? filtered,
    String? searchQuery,
    UnitsFilter? filter,
    AppError? error,
  }) {
    return UnitsListState(
      status: status ?? this.status,
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, all, filtered, searchQuery, filter, error];
}
