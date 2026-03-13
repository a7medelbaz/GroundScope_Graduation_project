import 'package:flutter/material.dart';
import '../../modules/worker/features/reports/ui/report_details_screen.dart';
import '../../modules/worker/features/task_details/ui/task_details_screen.dart';
import '../../modules/admin/features/home/admin_screen.dart';
import '../../modules/supervisor/features/home/supervisor_screen.dart';
import '../../modules/worker/core/main_navigation/ui/worker_scaffold.dart';
import '../auth/ui/login_screen.dart';
import '../onboarding/ui/on_boarding_screen.dart';
import 'routes.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case Routes.onBoardingScreen:
        return MaterialPageRoute(
          builder: (_) => const OnBoardingScreen(),
        );
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      // Worker
      case Routes.workerScaffold:
        return MaterialPageRoute(
          builder: (_) => const WorkerScaffold(),
        );
      case Routes.taskDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => TaskDetailsScreen(task: args!['task']),
        );
      case Routes.reportDetailsScreen:
        return MaterialPageRoute(
          builder: (_) =>
              ReportDetailsScreen(report: args!['report']),
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
