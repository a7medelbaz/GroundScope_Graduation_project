import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/add_report_screen.dart';
import 'package:ground_scope/modules/worker/features/task_details/logic/cubit/task_details_cubit.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/task_details_screen.dart';

class AppRouter {
  AppRouter._();
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case Routes.taskDetailsScreen:
        final task = arguments?['task'];
        return _buildRoute(
          BlocProvider(
            create: (context) =>
                getIt<TaskDetailsCubit>()..initTask(task: task),
            child: TaskDetailsScreen(task: task),
          ),
          settings,
        );
      case Routes.addReportScreen:
        final task = arguments?['preSelectedTask'] as TaskModel?;
        return _buildRoute(
          BlocProvider(
            create: (context) => getIt<AddReportCubit>()..fetchTasks(),
            child: AddReportScreen(preSelectedTask: task),
          ),
          settings,
        );
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
