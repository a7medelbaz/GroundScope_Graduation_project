part of 'stand_form_cubit.dart';

enum StandFormStatus { initial, submitting, success, failure }

class StandFormState extends Equatable {
  const StandFormState({
    this.status = StandFormStatus.initial,
    this.editing,
    this.error,
  });

  final StandFormStatus status;
  final StandModel? editing;
  final AppError? error;

  bool get isEditMode => editing != null;

  StandFormState copyWith({
    StandFormStatus? status,
    StandModel? editing,
    AppError? error,
  }) {
    return StandFormState(
      status: status ?? this.status,
      editing: editing ?? this.editing,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, editing, error];
}
