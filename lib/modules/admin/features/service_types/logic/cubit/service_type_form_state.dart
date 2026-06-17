part of 'service_type_form_cubit.dart';

enum ServiceTypeFormStatus { initial, submitting, success, failure }

class ServiceTypeFormState extends Equatable {
  const ServiceTypeFormState({
    this.status = ServiceTypeFormStatus.initial,
    this.editing,
    this.error,
    this.generatedCredentials,
    this.credentialsError = false,
  });

  final ServiceTypeFormStatus status;
  final ServiceTypeModel? editing;
  final AppError? error;
  final GeneratedCredentials? generatedCredentials;
  final bool credentialsError;

  bool get isEditMode => editing != null;

  ServiceTypeFormState copyWith({
    ServiceTypeFormStatus? status,
    ServiceTypeModel? editing,
    AppError? error,
    GeneratedCredentials? generatedCredentials,
    bool? credentialsError,
  }) {
    return ServiceTypeFormState(
      status: status ?? this.status,
      editing: editing ?? this.editing,
      error: error ?? this.error,
      generatedCredentials: generatedCredentials ?? this.generatedCredentials,
      credentialsError: credentialsError ?? this.credentialsError,
    );
  }

  @override
  List<Object?> get props =>
      [status, editing, error, generatedCredentials, credentialsError];
}
