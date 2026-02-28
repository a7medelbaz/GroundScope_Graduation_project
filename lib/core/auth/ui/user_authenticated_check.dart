import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/onboarding/ui/on_boarding_screen.dart';
import 'package:ground_scope/modules/admin/features/home/admin_screen.dart';
import 'package:ground_scope/modules/supervisor/features/home/supervisor_screen.dart';
import 'package:ground_scope/modules/worker/features/main_navigation/ui/worker_scaffold.dart';

class UserAuthenticatedCheck extends StatelessWidget {
  const UserAuthenticatedCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is AuthInitial || authState is AuthChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState is AuthSuccess) {
      return switch (authState.userData.position) {
        'worker' => const WorkerScaffold(),
        'supervisor' => const SupervisorScreen(),
        'admin' => const AdminScreen(),
        _ => const OnBoardingScreen(),
      };
    }

    return const OnBoardingScreen();
  }
}
