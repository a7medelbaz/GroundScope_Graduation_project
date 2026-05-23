part of 'admin_dashboard_cubit.dart';

class AdminDashboardState extends Equatable {
  const AdminDashboardState({this.adminName});

  final String? adminName;

  AdminDashboardState copyWith({String? adminName}) {
    return AdminDashboardState(adminName: adminName ?? this.adminName);
  }

  @override
  List<Object?> get props => [adminName];
}
