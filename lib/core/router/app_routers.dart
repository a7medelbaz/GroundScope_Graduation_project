import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/modules/admin/features/dashboard/logic/cubit/admin_dashboard_cubit.dart';
import 'package:ground_scope/modules/admin/features/dashboard/ui/admin_dashboard_screen.dart';
import 'package:ground_scope/modules/admin/features/flights/logic/cubit/flights_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/flight_detail_screen.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/flights_list_screen.dart';
import 'package:ground_scope/modules/admin/features/service_types/logic/cubit/service_type_form_cubit.dart';
import 'package:ground_scope/modules/admin/features/service_types/logic/cubit/service_types_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/service_type_form_screen.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/service_types_list_screen.dart';
import 'package:ground_scope/modules/admin/features/stands/logic/cubit/stand_form_cubit.dart';
import 'package:ground_scope/modules/admin/features/stands/logic/cubit/stands_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/stands/ui/stand_form_screen.dart';
import 'package:ground_scope/modules/admin/features/stands/ui/stands_list_screen.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/unit_detail_cubit.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/unit_form_cubit.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/units_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/units/ui/unit_detail_screen.dart';
import 'package:ground_scope/modules/admin/features/units/ui/unit_form_screen.dart';
import 'package:ground_scope/modules/admin/features/units/ui/units_list_screen.dart';
import 'package:ground_scope/modules/admin/features/users/logic/cubit/user_reset_cubit.dart';
import 'package:ground_scope/modules/admin/features/users/logic/cubit/users_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/users/ui/users_list_screen.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/add_report_screen.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/manager_and_members_screen.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/member_detail_screen.dart';
import 'package:ground_scope/modules/worker/features/reports/logic/cubit/reports_cubit.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/report_details_screen.dart';
import 'package:ground_scope/modules/worker/features/task_details/logic/cubit/task_details_cubit.dart';
import 'package:ground_scope/modules/worker/features/task_details/ui/task_details_screen.dart';
import 'package:ground_scope/modules/worker/features/task_info/ui/task_info_screen.dart';

import '../../modules/admin/features/reports/logic/cubit/admin_reports_cubit.dart';
import '../../modules/admin/features/reports/ui/admin_report_detail_screen.dart';
import '../../modules/admin/features/reports/ui/admin_reports_screen.dart';
import '../../modules/admin/features/service_requests/logic/cubit/service_request_cubit.dart';
import '../../modules/admin/features/service_requests/ui/flight_service_request_screen.dart';
import '../../modules/supervisor/core/main_navigation/supervisor_scaffold.dart';
import '../../modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart';
import '../../modules/supervisor/features/reports/ui/supervisor_forward_report_screen.dart';
import '../../modules/supervisor/features/reports/ui/supervisor_report_detail_screen.dart';
import '../../modules/supervisor/features/reports/ui/supervisor_send_report_screen.dart';
import '../../modules/supervisor/features/tasks/logic/cubit/supervisor_task_detail_cubit.dart';
import '../../modules/supervisor/features/tasks/ui/supervisor_task_detail_screen.dart';
import '../../modules/worker/core/main_navigation/ui/worker_scaffold.dart';
import '../auth/ui/login_screen.dart';
import '../notifications/logic/cubit/notification_cubit.dart';
import '../notifications/ui/notifications_screen.dart';
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
      case Routes.supervisorScaffold:
        return _buildRoute(const SupervisorScaffold(), settings);
      case Routes.supervisorTaskDetailScreen:
        final taskId =
            (settings.arguments as Map<String, dynamic>)['taskId'] as String;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<SupervisorTaskDetailCubit>()..loadTask(taskId),
            child: SupervisorTaskDetailScreen(taskId: taskId),
          ),
          settings,
        );
      case Routes.supervisorReportDetailScreen:
        final report = arguments?['report'] as ReportModel;
        final reportsCubit = arguments?['cubit'] as SupervisorReportsCubit;
        return _buildRoute(
          BlocProvider.value(
            value: reportsCubit,
            child: SupervisorReportDetailScreen(report: report),
          ),
          settings,
        );
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
        if (manager == null) {
          return _buildRoute(const SizedBox.shrink(), settings);
        }
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

      // Admin-----------------------------------------------
      case Routes.adminDashboardScreen:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<AdminDashboardCubit>()..load(),
            child: const AdminDashboardScreen(),
          ),
          settings,
        );

      case Routes.adminServiceTypesScreen:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<ServiceTypesListCubit>(),
            child: const ServiceTypesListScreen(),
          ),
          settings,
        );

      case Routes.adminServiceTypeFormScreen:
        final model = arguments?['model'] as ServiceTypeModel?;
        return _buildRoute(
          BlocProvider(
            create: (_) {
              final cubit = getIt<ServiceTypeFormCubit>();
              if (model != null) cubit.initForEdit(model);
              return cubit;
            },
            child: const ServiceTypeFormScreen(),
          ),
          settings,
        );

      case Routes.adminStandsScreen:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<StandsListCubit>()..load(),
            child: const StandsListScreen(),
          ),
          settings,
        );

      case Routes.adminStandFormScreen:
        final model = arguments?['model'] as StandModel?;
        return _buildRoute(
          BlocProvider(
            create: (_) {
              final cubit = getIt<StandFormCubit>();
              if (model != null) cubit.initForEdit(model);
              return cubit;
            },
            child: const StandFormScreen(),
          ),
          settings,
        );

      case Routes.adminFlightsScreen:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<FlightsListCubit>()..load(),
            child: const FlightsListScreen(),
          ),
          settings,
        );

      case Routes.adminUnitsScreen:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<UnitsListCubit>()..load(),
            child: const UnitsListScreen(),
          ),
          settings,
        );

      case Routes.adminUnitDetailScreen:
        final unit =
            (settings.arguments as Map<String, dynamic>)['unit'] as UnitModel;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<UnitDetailCubit>()..load(unit.id),
            child: UnitDetailScreen(unit: unit),
          ),
          settings,
        );

      case Routes.adminUnitFormScreen:
        final formArgs = settings.arguments as Map<String, dynamic>?;
        final editModel = formArgs?['model'] as UnitModel?;
        return _buildRoute(
          BlocProvider(
            create: (_) {
              final cubit = getIt<UnitFormCubit>()..init();
              if (editModel != null) cubit.initForEdit(editModel);
              return cubit;
            },
            child: const UnitFormScreen(),
          ),
          settings,
        );

      case Routes.adminFlightDetailScreen:
        final flight = arguments?['flight'] as FlightModel;
        final cubit = arguments?['cubit'] as FlightsListCubit;
        return _buildRoute(
          BlocProvider.value(
            value: cubit,
            child: FlightDetailScreen(flight: flight),
          ),
          settings,
        );

      case Routes.adminFlightServiceRequestScreen:
        final flight = arguments?['flight'] as FlightModel;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<ServiceRequestCubit>()..init(flight),
            child: FlightServiceRequestScreen(flight: flight),
          ),
          settings,
        );

      case Routes.adminUsersScreen:
        return _buildRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<UsersListCubit>()..load()),
              BlocProvider(create: (_) => getIt<UserResetCubit>()),
            ],
            child: const UsersListScreen(),
          ),
          settings,
        );

      case Routes.notificationsScreen:
        return _buildRoute(
          BlocProvider.value(
            value: getIt<NotificationCubit>(),
            child: const NotificationsScreen(),
          ),
          settings,
        );

      // Supervisor reports (new)────────────────────────────────────────────────
      case Routes.supervisorSendReportScreen:
        final supervisorsCubit = arguments?['cubit'] as SupervisorReportsCubit;
        final serviceTypeId = arguments?['serviceTypeId'] as String;
        final isBroadcast = arguments?['isBroadcast'] as bool? ?? false;
        return _buildRoute(
          BlocProvider.value(
            value: supervisorsCubit,
            child: SupervisorSendReportScreen(
              serviceTypeId: serviceTypeId,
              isBroadcast: isBroadcast,
            ),
          ),
          settings,
        );

      case Routes.supervisorForwardReportScreen:
        final fwdCubit = arguments?['cubit'] as SupervisorReportsCubit;
        final originalReport = arguments?['report'] as ReportModel;
        return _buildRoute(
          BlocProvider.value(
            value: fwdCubit,
            child: SupervisorForwardReportScreen(report: originalReport),
          ),
          settings,
        );

      // Admin reports (new)─────────────────────────────────────────────────────
      case Routes.adminReportsScreen:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<AdminReportsCubit>()..load(),
            child: const AdminReportsScreen(),
          ),
          settings,
        );

      case Routes.adminReportDetailScreen:
        final detailReport = arguments?['report'] as ReportModel;
        return _buildRoute(
          AdminReportDetailScreen(report: detailReport),
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
