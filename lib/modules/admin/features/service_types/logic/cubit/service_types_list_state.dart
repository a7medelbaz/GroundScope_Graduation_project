part of 'service_types_list_cubit.dart';

enum ServiceTypesFilter { all, active, inactive }

enum ServiceTypesListStatus { initial, loading, success, failure }

class ServiceTypesListState extends Equatable {
  const ServiceTypesListState({
    this.status = ServiceTypesListStatus.initial,
    this.all = const [],
    this.filtered = const [],
    this.searchQuery = '',
    this.filter = ServiceTypesFilter.all,
    this.error,
  });

  final ServiceTypesListStatus status;
  final List<ServiceTypeModel> all;
  final List<ServiceTypeModel> filtered;
  final String searchQuery;
  final ServiceTypesFilter filter;
  final AppError? error;

  ServiceTypesListState copyWith({
    ServiceTypesListStatus? status,
    List<ServiceTypeModel>? all,
    List<ServiceTypeModel>? filtered,
    String? searchQuery,
    ServiceTypesFilter? filter,
    AppError? error,
  }) {
    return ServiceTypesListState(
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
