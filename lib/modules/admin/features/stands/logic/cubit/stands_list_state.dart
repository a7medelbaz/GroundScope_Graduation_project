part of 'stands_list_cubit.dart';

enum StandsFilter { all, active, inactive }

enum StandsListStatus { initial, loading, success, failure }

class StandsListState extends Equatable {
  const StandsListState({
    this.status = StandsListStatus.initial,
    this.all = const [],
    this.filtered = const [],
    this.searchQuery = '',
    this.filter = StandsFilter.all,
    this.error,
  });

  final StandsListStatus status;
  final List<StandModel> all;
  final List<StandModel> filtered;
  final String searchQuery;
  final StandsFilter filter;
  final AppError? error;

  StandsListState copyWith({
    StandsListStatus? status,
    List<StandModel>? all,
    List<StandModel>? filtered,
    String? searchQuery,
    StandsFilter? filter,
    AppError? error,
  }) {
    return StandsListState(
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
