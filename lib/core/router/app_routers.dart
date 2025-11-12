import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/ui/login_screen.dart';
import 'package:ground_scope/core/onboarding/ui/on_boarding_screen.dart';
import 'package:ground_scope/core/router/routes.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    // ignore: unused_local_variable
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.onBoardingScreen:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
