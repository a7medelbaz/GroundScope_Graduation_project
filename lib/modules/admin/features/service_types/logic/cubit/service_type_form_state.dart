part of 'service_type_form_cubit.dart';

enum ServiceTypeFormStatus { initial, submitting, success, failure }

class ServiceTypeFormState extends Equatable {
  const ServiceTypeFormState({
    this.status = ServiceTypeFormStatus.initial,
    this.editing,
    this.error,
  });

  final ServiceTypeFormStatus status;
  final ServiceTypeModel? editing;
  final AppError? error;

  bool get isEditMode => editing != null;

  ServiceTypeFormState copyWith({
    ServiceTypeFormStatus? status,
    ServiceTypeModel? editing,
    AppError? error,
  }) {
    return ServiceTypeFormState(
      status: status ?? this.status,
      editing: editing ?? this.editing,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, editing, error];
}
