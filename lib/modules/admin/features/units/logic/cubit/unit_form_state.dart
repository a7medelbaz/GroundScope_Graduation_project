part of 'unit_form_cubit.dart';

enum UnitFormStatus { initial, submitting, success, failure }

class UnitFormState extends Equatable {
  const UnitFormState({
    this.status = UnitFormStatus.initial,
    this.editing,
    this.serviceTypes = const [],
    this.error,
    this.generatedCredentials,
    this.credentialsError = false,
  });

  final UnitFormStatus status;
  final UnitModel? editing;
  final List<ServiceTypeModel> serviceTypes;
  final AppError? error;
  final GeneratedCredentials? generatedCredentials;
  final bool credentialsError;

  bool get isEditMode => editing != null;

  UnitFormState copyWith({
    UnitFormStatus? status,
    UnitModel? editing,
    List<ServiceTypeModel>? serviceTypes,
    AppError? error,
    GeneratedCredentials? generatedCredentials,
    bool? credentialsError,
  }) {
    return UnitFormState(
      status: status ?? this.status,
      editing: editing ?? this.editing,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      error: error ?? this.error,
      generatedCredentials: generatedCredentials ?? this.generatedCredentials,
      credentialsError: credentialsError ?? this.credentialsError,
    );
  }

  @override
  List<Object?> get props =>
      [status, editing, serviceTypes, error, generatedCredentials, credentialsError];
}
