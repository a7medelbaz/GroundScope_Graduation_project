part of 'unit_form_cubit.dart';

enum UnitFormStatus { initial, submitting, success, failure }

class UnitFormState extends Equatable {
  const UnitFormState({
    this.status = UnitFormStatus.initial,
    this.editing,
    this.serviceTypes = const [],
    this.error,
  });

  final UnitFormStatus status;
  final UnitModel? editing;
  final List<ServiceTypeModel> serviceTypes;
  final AppError? error;

  bool get isEditMode => editing != null;

  UnitFormState copyWith({
    UnitFormStatus? status,
    UnitModel? editing,
    List<ServiceTypeModel>? serviceTypes,
    AppError? error,
  }) {
    return UnitFormState(
      status: status ?? this.status,
      editing: editing ?? this.editing,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, editing, serviceTypes, error];
}
