import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/service/user_service.dart';

part 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit(this._userService) : super(const AdminDashboardState());

  final UserService _userService;

  Future<void> load() async {
    final user = await _userService.getUser();
    emit(state.copyWith(adminName: user?.fullName));
  }
}
