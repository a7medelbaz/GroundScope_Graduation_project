import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/logic/cubit/dashboard_cubit.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import 'package:ground_scope/modules/worker/features/profile/logic/cubit/profile_cubit.dart';
import 'package:ground_scope/modules/worker/features/reports/logic/cubit/reports_cubit.dart';
import '../../../modules/admin/features/home/admin_screen.dart';
import '../../../modules/supervisor/core/main_navigation/supervisor_scaffold.dart';
import '../../../modules/worker/core/main_navigation/ui/worker_scaffold.dart';
import '../../../modules/worker/features/home/logic/cubit/home_cubit.dart';
import '../../di/dependency_injection.dart';
import '../../onboarding/ui/on_boarding_screen.dart';
import '../logic/cubit/auth_cubit.dart';

class UserAuthenticatedCheck extends StatelessWidget {
  const UserAuthenticatedCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthInitial || authState is AuthChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authState is AuthSuccess) {
      return switch (authState.userModel.role) {
        'unit_manager' => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<HomeCubit>()..init()),
            BlocProvider(create: (_) => getIt<AddReportCubit>()..fetchTasks()),
            BlocProvider(create: (_) => getIt<ReportsCubit>()..fetchMyReports()),
            BlocProvider(create: (_) => getIt<ProfileCubit>()),
          ],
          child: const WorkerScaffold(),
        ),
        'supervisor' => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => getIt<DashboardCubit>()..loadDashboardStats(),
            ),
          ],
          child: const SupervisorScaffold(),
        ),
        'admin' => const AdminScreen(),
        _ => const OnBoardingScreen(),
      };
    }
    return const OnBoardingScreen();
  }
}
