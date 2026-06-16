import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import 'package:ground_scope/modules/worker/features/reports/logic/cubit/reports_cubit.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/add_report_screen.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/manager_and_members_screen.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/member_detail_screen.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/report_details_screen.dart';
import 'package:ground_scope/modules/worker/features/task_details/logic/cubit/task_details_cubit.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/task_details_screen.dart';
import 'package:ground_scope/modules/worker/features/task_info/ui/task_info_screen.dart';
import '../../modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart';
import '../../modules/supervisor/features/reports/ui/supervisor_reports_screen.dart';
import '../../modules/supervisor/features/tasks/logic/cubit/supervisor_task_list_cubit.dart';
import '../../modules/supervisor/features/tasks/ui/supervisor_task_list_screen.dart';
import '../../modules/supervisor/features/units/logic/cubit/units_list_cubit.dart';
import '../../modules/supervisor/features/units/ui/units_screen.dart';
import '../../modules/worker/core/main_navigation/ui/worker_scaffold.dart';
import '../auth/ui/login_screen.dart';
import '../onboarding/ui/on_boarding_screen.dart';

class AppRouter {
  AppRouter._();
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      // Auth-----------------------------------------------
      case Routes.onBoardingScreen:
        return _buildRoute(const OnBoardingScreen(), settings);
      case Routes.loginScreen:
        return _buildRoute(const LoginScreen(), settings);

      // Worker-----------------------------------------------
      case Routes.workerScaffold:
        return _buildRoute(const WorkerScaffold(), settings);
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
      case Routes.taskDetailsInfoScreen:
        final task = arguments?['task'];
        return _buildRoute(
          BlocProvider(
            create: (context) =>
                getIt<TaskDetailsCubit>()..initTask(task: task),
            child: TaskInfoScreen(task: task, pauses: const []),
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
      case Routes.reportsDetailsScreen:
        final report = arguments?['report'] as ReportModel;
        final cubit = arguments?['cubit'] as ReportsCubit;
        return _buildRoute(
          BlocProvider.value(
            value: cubit,
            child: ReportDetailsScreen(report: report),
          ),
          settings,
        );

      // Worker Profile routes ─────────────────────────────────────────────
      case Routes.workerManagerAndMembersScreen:
        final manager = arguments?['manager'] as UserModel?;
        final members =
            (arguments?['members'] as List?)?.cast<UnitMemberModel>() ?? [];
        if (manager == null) return _buildRoute(const SizedBox.shrink(), settings);
        return _buildRoute(
          ManagerAndMembersScreen(manager: manager, members: members),
          settings,
        );

      case Routes.workerMemberDetailScreen:
        final member = arguments?['member'] as UnitMemberModel?;
        if (member == null) {
          return _buildRoute(const SizedBox.shrink(), settings);
        }
        return _buildRoute(MemberDetailScreen(member: member), settings);

      // Supervisor-----------------------------------------------
      case Routes.supervisorUnitsScreen:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<UnitsListCubit>()..loadUnits(),
            child: const SupervisorUnitsScreen(),
          ),
          settings,
        );

      case Routes.supervisorReportsScreen:
        return _buildRoute(
          BlocProvider(
            create: (_) =>
                getIt<SupervisorReportsCubit>()..loadReportsToday(),
            child: const SupervisorReportsScreen(),
          ),
          settings,
        );

      case Routes.supervisorTaskListScreen:
        final title = arguments?['title'] as String? ?? 'Tasks';
        final accentColor = arguments?['accentColor'] as Color? ?? Colors.blue;
        final filterStatus =
            arguments?['filterStatus'] as TaskStatus? ?? TaskStatus.completed;
        return _buildRoute(
          BlocProvider(
            create: (_) =>
                getIt<SupervisorTaskListCubit>()..loadTasks(filterStatus),
            child: SupervisorTaskListScreen(
              title: title,
              accentColor: accentColor,
              filterStatus: filterStatus,
            ),
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
