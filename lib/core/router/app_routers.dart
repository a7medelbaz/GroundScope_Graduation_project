import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/modules/admin/features/home/admin_screen.dart';
import 'package:ground_scope/modules/supervisor/features/home/supervisor_screen.dart';
import '../auth/data/repo/auth_repo.dart';
import '../di/dependency_injection.dart';
import '../auth/logic/cubit/auth_cubit.dart';
import '../../modules/worker/features/home/ui/widgets/worker_screen.dart';
import '../auth/ui/login_screen.dart';
import '../onboarding/ui/on_boarding_screen.dart';
import 'routes.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    // ignore: unused_local_variable
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.onBoardingScreen:
        return MaterialPageRoute(
          builder: (_) => const OnBoardingScreen(),
        );
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthCubit(getIt<AuthRepo>()),
            child: const LoginScreen(),
          ),
        );
      case Routes.workerScreen:
        return MaterialPageRoute(
          builder: (_) => const WorkerScreen(),
        );
      case Routes.supervisorScreen:
        return MaterialPageRoute(
          builder: (_) => const SupervisorScreen(),
        );
      case Routes.adminScreen:
        return MaterialPageRoute(builder: (_) => const AdminScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
