part of 'unit_member_cubit.dart';

enum UnitMemberFormStatus { initial, submitting, success, failure }

class UnitMemberState extends Equatable {
  const UnitMemberState({
    this.status = UnitMemberFormStatus.initial,
    this.editing,
    this.error,
  });

  final UnitMemberFormStatus status;
  final UnitMemberModel? editing;
  final AppError? error;

  bool get isEditMode => editing != null;

  UnitMemberState copyWith({
    UnitMemberFormStatus? status,
    UnitMemberModel? editing,
    AppError? error,
  }) {
    return UnitMemberState(
      status: status ?? this.status,
      editing: editing ?? this.editing,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, editing, error];
}
