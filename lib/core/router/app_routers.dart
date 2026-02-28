import 'package:flutter/material.dart';

import '../../modules/admin/features/home/admin_screen.dart';
import '../../modules/supervisor/features/home/supervisor_screen.dart';
import '../../modules/worker/features/main_navigation/ui/worker_scaffold.dart';
import '../auth/ui/login_screen.dart';
import '../onboarding/ui/on_boarding_screen.dart';
import 'routes.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    // ignore: unused_local_variable
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.onBoardingScreen:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.workerScaffold:
        return MaterialPageRoute(builder: (_) => const WorkerScaffold());
      case Routes.supervisorScreen:
        return MaterialPageRoute(builder: (_) => const SupervisorScreen());
      case Routes.adminScreen:
        return MaterialPageRoute(builder: (_) => const AdminScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
