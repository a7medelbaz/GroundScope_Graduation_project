part of 'units_list_cubit.dart';

sealed class UnitsListState extends Equatable {
  const UnitsListState();

  @override
  List<Object?> get props => [];
}

final class UnitsListInitial extends UnitsListState {}

final class UnitsListLoading extends UnitsListState {}

final class UnitsListLoaded extends UnitsListState {
  const UnitsListLoaded({
    required this.allUnits,
    required this.filteredUnits,
    this.searchQuery = '',
  });

  final List<UnitProfileModel> allUnits;
  final List<UnitProfileModel> filteredUnits;
  final String searchQuery;

  UnitsListLoaded copyWith({
    List<UnitProfileModel>? allUnits,
    List<UnitProfileModel>? filteredUnits,
    String? searchQuery,
  }) {
    return UnitsListLoaded(
      allUnits: allUnits ?? this.allUnits,
      filteredUnits: filteredUnits ?? this.filteredUnits,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allUnits, filteredUnits, searchQuery];
}

final class UnitsListFailure extends UnitsListState {
  const UnitsListFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}
