// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Add this import
import 'package:ground_scope/core/auth/ui/login_screen.dart';
import 'package:ground_scope/core/onboarding/ui/on_boarding_screen.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/modules/admin/features/home/admin_screen.dart';
import 'package:ground_scope/modules/supervisor/features/home/supervisor_screen.dart';
import 'package:ground_scope/modules/worker/core/main_navigation/ui/worker_scaffold.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/task_details_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(final RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case Routes.onBoardingScreen:
        return _buildRoute(const OnBoardingScreen(), settings);
      case Routes.loginScreen:
        return _buildRoute(const LoginScreen(), settings);
      case Routes.workerScaffold:
        return _buildRoute(const WorkerScaffold(), settings);
      case Routes.taskDetailsScreen:
        return _buildRoute(const TaskDetailsScreen(), settings);
      case Routes.supervisorScreen:
        return _buildRoute(const SupervisorScreen(), settings);
      case Routes.adminScreen:
        return _buildRoute(const AdminScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(
    final Widget page,
    final RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (final context, final animation, final secondaryAnimation) =>
          page,
      transitionsBuilder:
          (
            final context,
            final animation,
            final secondaryAnimation,
            final child,
          ) {
            return child
                .animate(adapter: ValueAdapter(animation.value))
                .fade(duration: 400.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOutCubic,
                )
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                );
          },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
