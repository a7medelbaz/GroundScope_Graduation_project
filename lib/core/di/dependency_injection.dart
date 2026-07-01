import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ground_scope/core/shared/data/remote/report_remote_ds.dart';
import 'package:ground_scope/core/shared/data/remote/service_type_remote_ds.dart';
import 'package:ground_scope/core/shared/data/remote/stand_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo_impl.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo_impl.dart';
import 'package:ground_scope/core/shared/data/repo/stand_repo.dart';
import 'package:ground_scope/core/shared/data/repo/stand_repo_impl.dart';
import 'package:ground_scope/modules/admin/features/dashboard/logic/cubit/admin_dashboard_cubit.dart';
import 'package:ground_scope/modules/admin/features/service_types/logic/cubit/service_type_form_cubit.dart';
import 'package:ground_scope/modules/admin/features/service_types/logic/cubit/service_types_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/stands/logic/cubit/stand_form_cubit.dart';
import 'package:ground_scope/modules/admin/features/stands/logic/cubit/stands_list_cubit.dart';
import '../../modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import '../../modules/worker/features/home/logic/cubit/home_cubit.dart';
import '../../modules/worker/features/profile/logic/cubit/profile_cubit.dart';
import '../../modules/worker/features/reports/logic/cubit/reports_cubit.dart';
import '../../modules/worker/features/task_details/data/remote/task_details_remote_ds.dart';
import '../../modules/worker/features/task_details/data/repo/task_details_repo.dart';
import '../../modules/worker/features/task_details/data/repo/task_details_repo_impl.dart';
import '../../modules/worker/features/task_details/logic/cubit/task_details_cubit.dart';
import '../auth/data/remote/auth_remote_ds.dart';
import '../auth/data/repo/auth_repo.dart';
import '../auth/data/repo/auth_repo_impl.dart';
import '../auth/logic/cubit/auth_cubit.dart';
import '../networking/supabase_service.dart';
import '../service/secure_storage.dart';
import '../service/user_service.dart';
import '../shared/data/remote/aviation_stack_remote_ds.dart';
import '../shared/data/remote/flights_remote_ds.dart';
import '../shared/data/remote/task_remote_ds.dart';
import '../shared/data/remote/unit_remote_ds.dart';
import '../shared/data/repo/flight_repo.dart';
import '../shared/data/repo/flight_repo_impl.dart';
import '../shared/data/repo/task_repo.dart';
import '../shared/data/repo/task_repo_impl.dart';
import '../shared/data/remote/unit_member_remote_ds.dart';
import '../shared/data/repo/unit_member_repo.dart';
import '../shared/data/repo/unit_member_repo_impl.dart';
import '../shared/data/repo/unit_repo.dart';
import '../shared/data/repo/unit_repo_impl.dart';
import '../../modules/admin/features/flights/logic/cubit/flight_import_cubit.dart';
import '../../modules/admin/features/flights/logic/cubit/flights_list_cubit.dart';
import '../../modules/admin/features/units/logic/cubit/units_list_cubit.dart';
import '../../modules/admin/features/units/logic/cubit/unit_detail_cubit.dart';
import '../../modules/admin/features/units/logic/cubit/unit_form_cubit.dart';
import '../../modules/admin/features/units/logic/cubit/unit_member_cubit.dart';
import '../../modules/admin/features/users/logic/cubit/users_list_cubit.dart';
import '../../modules/admin/features/users/logic/cubit/user_reset_cubit.dart';
import '../shared/data/remote/user_remote_ds.dart';
import '../shared/data/repo/user_repo.dart';
import '../shared/data/repo/user_repo_impl.dart';
import '../../modules/supervisor/features/dashboard/data/remote/dashboard_remote_ds.dart';
import '../../modules/supervisor/features/dashboard/data/repo/dashboard_repo.dart';
import '../../modules/supervisor/features/dashboard/data/repo/dashboard_repo_impl.dart';
import '../../modules/supervisor/features/dashboard/data/remote/assign_unit_remote_ds.dart';
import '../../modules/supervisor/features/dashboard/data/repo/assign_unit_repo.dart';
import '../../modules/supervisor/features/dashboard/data/repo/assign_unit_repo_impl.dart';
import '../../modules/supervisor/features/dashboard/logic/cubit/assign_unit_cubit.dart';
import '../../modules/supervisor/features/dashboard/logic/cubit/dashboard_cubit.dart';
import '../../modules/supervisor/features/tasks/data/remote/supervisor_task_remote_ds.dart';
import '../../modules/supervisor/features/tasks/data/repo/supervisor_task_repo.dart';
import '../../modules/supervisor/features/tasks/data/repo/supervisor_task_repo_impl.dart';
import '../../modules/supervisor/features/tasks/logic/cubit/supervisor_task_detail_cubit.dart';
import '../../modules/supervisor/features/tasks/logic/cubit/supervisor_tasks_cubit.dart';
import '../../modules/supervisor/features/units/data/remote/supervisor_units_remote_ds.dart';
import '../../modules/supervisor/features/units/data/repo/supervisor_units_repo.dart';
import '../../modules/supervisor/features/units/data/repo/supervisor_units_repo_impl.dart';
import '../../modules/supervisor/features/units/logic/cubit/supervisor_units_cubit.dart';
import '../../modules/supervisor/features/reports/data/remote/supervisor_reports_remote_ds.dart';
import '../../modules/supervisor/features/reports/data/repo/supervisor_reports_repo.dart';
import '../../modules/supervisor/features/reports/data/repo/supervisor_reports_repo_impl.dart';
import '../../modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart';
import '../../modules/supervisor/features/profile/logic/cubit/supervisor_profile_cubit.dart';
import '../../modules/supervisor/features/add_report/data/remote/supervisor_add_report_remote_ds.dart';
import '../../modules/supervisor/features/add_report/data/repo/supervisor_add_report_repo.dart';
import '../../modules/supervisor/features/add_report/data/repo/supervisor_add_report_repo_impl.dart';
import '../../modules/supervisor/features/add_report/logic/cubit/supervisor_add_report_cubit.dart';
import '../shared/data/remote/service_request_remote_ds.dart';
import '../shared/data/repo/service_request_repo.dart';
import '../shared/data/repo/service_request_repo_impl.dart';
import '../../modules/admin/features/service_requests/logic/cubit/service_request_cubit.dart';
import '../../modules/admin/features/reports/logic/cubit/admin_reports_cubit.dart';
import '../notifications/data/remote/notification_remote_ds.dart';
import '../notifications/data/repo/notification_repo.dart';
import '../notifications/data/repo/notification_repo_impl.dart';
import '../notifications/logic/cubit/notification_cubit.dart';

final getIt = GetIt.instance;
Future<void> setUpDependencies() async {
  final FlutterSecureStorage flutterSecureStorage =
      const FlutterSecureStorage();

  if (!getIt.isRegistered<SecureStorage>()) {
    getIt.registerLazySingleton<SecureStorage>(
      () => SecureStorage(flutterSecureStorage),
    );
  }
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());

  getIt.registerLazySingleton<UserService>(
    () => UserService(secureStorage: getIt<SecureStorage>()),
  );

  // Shared DI
  // #Unit DI
  getIt.registerLazySingleton<UnitRemoteDs>(
    () => UnitRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<UnitRepo>(
    () => UnitRepoImpl(unitRemoteDs: getIt<UnitRemoteDs>()),
  );
  // #Task DI
  getIt.registerLazySingleton<TaskRemoteDs>(
    () => TaskRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<TaskRepo>(
    () => TaskRepoImpl(taskRemoteDs: getIt<TaskRemoteDs>()),
  );
  // #Reports DI
  getIt.registerLazySingleton<ReportRemoteDs>(
    () => ReportRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<ReportRepo>(
    () => ReportRepoImpl(reportRemoteDs: getIt<ReportRemoteDs>()),
  );

  // #ServiceType DI
  getIt.registerLazySingleton<ServiceTypeRemoteDs>(
    () => ServiceTypeRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<ServiceTypeRepo>(
    () => ServiceTypeRepoImpl(
      serviceTypeRemoteDs: getIt<ServiceTypeRemoteDs>(),
    ),
  );

  /// Auth DI
  getIt.registerLazySingleton<AuthRemoteDs>(
    () => AuthRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      authRemoteDs: getIt<AuthRemoteDs>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));

  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      unitRepo: getIt<UnitRepo>(),
      userService: getIt<UserService>(),
      taskRepo: getIt<TaskRepo>(),
    ),
  );
  // Flight DI
  getIt.registerLazySingleton<FlightsRemoteDs>(
    () => FlightsRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<FlightRepo>(
    () => FlightRepoImpl(flightsRemoteDs: getIt<FlightsRemoteDs>()),
  );
  getIt.registerLazySingleton<AviationStackRemoteDs>(
    () => AviationStackRemoteDs(),
  );
  getIt.registerFactory<FlightsListCubit>(
    () => FlightsListCubit(getIt<FlightRepo>()),
  );
  getIt.registerFactory<FlightImportCubit>(
    () => FlightImportCubit(getIt<AviationStackRemoteDs>(), getIt<FlightRepo>()),
  );

  // Task Details DI
  getIt.registerLazySingleton<TaskDetailsRemoteDs>(
    () => TaskDetailsRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<TaskDetailsRepo>(
    () =>
        TaskDetailsRepoImpl(taskDetailsRemoteDs: getIt<TaskDetailsRemoteDs>()),
  );
  getIt.registerFactory<TaskDetailsCubit>(
    () => TaskDetailsCubit(
      taskDetailsRepo: getIt<TaskDetailsRepo>(),
      taskRepo: getIt<TaskRepo>(),
      userService: getIt<UserService>(),
    ),
  );

  // AddReport DI
  getIt.registerFactory<AddReportCubit>(
    () => AddReportCubit(
      reportRepo: getIt<ReportRepo>(),
      userService: getIt<UserService>(),
      taskRepo: getIt<TaskRepo>(),
      userRemoteDs: getIt<UserRemoteDs>(),
    ),
  );

  // Reports DI
  getIt.registerFactory<ReportsCubit>(
    () => ReportsCubit(
      reportRepo: getIt<ReportRepo>(),
      userService: getIt<UserService>(),
    ),
  );

  // Admin DI
  getIt.registerFactory<AdminDashboardCubit>(
    () => AdminDashboardCubit(
      getIt<UserService>(),
      getIt<FlightRepo>(),
      getIt<TaskRepo>(),
      getIt<ReportRepo>(),
      getIt<UnitRepo>(),
    ),
  );
  getIt.registerFactory<ServiceTypesListCubit>(
    () => ServiceTypesListCubit(getIt<ServiceTypeRepo>()),
  );
  // #User DI
  getIt.registerLazySingleton<UserRemoteDs>(
    () => UserRemoteDs(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<UserRepo>(
    () => UserRepoImpl(getIt<UserRemoteDs>()),
  );
  getIt.registerFactory<UsersListCubit>(
    () => UsersListCubit(getIt<UserRepo>()),
  );
  getIt.registerFactory<UserResetCubit>(
    () => UserResetCubit(getIt<UserRepo>()),
  );

  getIt.registerFactory<ServiceTypeFormCubit>(
    () => ServiceTypeFormCubit(getIt<ServiceTypeRepo>(), getIt<UserRepo>()),
  );

  // #Stand DI
  getIt.registerLazySingleton<StandRemoteDs>(
    () => StandRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<StandRepo>(
    () => StandRepoImpl(standRemoteDs: getIt<StandRemoteDs>()),
  );
  getIt.registerFactory<StandsListCubit>(
    () => StandsListCubit(getIt<StandRepo>()),
  );
  getIt.registerFactory<StandFormCubit>(
    () => StandFormCubit(getIt<StandRepo>()),
  );

  // Admin Units DI
  getIt.registerFactory<UnitsListCubit>(
    () => UnitsListCubit(getIt<UnitRepo>()),
  );
  getIt.registerFactory<UnitDetailCubit>(
    () => UnitDetailCubit(getIt<UnitRepo>(), getIt<UnitMemberRepo>()),
  );
  getIt.registerFactory<UnitFormCubit>(
    () => UnitFormCubit(
        getIt<UnitRepo>(), getIt<ServiceTypeRepo>(), getIt<UserRepo>()),
  );
  getIt.registerFactory<UnitMemberCubit>(
    () => UnitMemberCubit(getIt<UnitMemberRepo>()),
  );

  // Profile DI
  getIt.registerLazySingleton<UnitMemberRemoteDs>(
    () => UnitMemberRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<UnitMemberRepo>(
    () => UnitMemberRepoImpl(unitMemberRemoteDs: getIt<UnitMemberRemoteDs>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<UnitRepo>(), getIt<UnitMemberRepo>()),
  );

  // === SUPERVISOR MODULE ===
  getIt.registerLazySingleton<DashboardRemoteDs>(
    () => DashboardRemoteDs(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<DashboardRepo>(
    () => DashboardRepoImpl(getIt<DashboardRemoteDs>()),
  );
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      dashboardRepo: getIt<DashboardRepo>(),
      userService: getIt<UserService>(),
    ),
  );
  getIt.registerLazySingleton<AssignUnitRemoteDs>(
    () => AssignUnitRemoteDs(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<AssignUnitRepo>(
    () => AssignUnitRepoImpl(getIt<AssignUnitRemoteDs>()),
  );
  getIt.registerFactory<AssignUnitCubit>(
    () => AssignUnitCubit(
      repo: getIt<AssignUnitRepo>(),
      userService: getIt<UserService>(),
    ),
  );
  getIt.registerLazySingleton<SupervisorTaskRemoteDs>(
    () => SupervisorTaskRemoteDs(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<SupervisorTaskRepo>(
    () => SupervisorTaskRepoImpl(getIt<SupervisorTaskRemoteDs>()),
  );
  getIt.registerFactory<SupervisorTasksCubit>(
    () => SupervisorTasksCubit(repo: getIt<SupervisorTaskRepo>()),
  );
  getIt.registerFactory<SupervisorTaskDetailCubit>(
    () => SupervisorTaskDetailCubit(repo: getIt<SupervisorTaskRepo>()),
  );
  getIt.registerLazySingleton<SupervisorUnitsRemoteDs>(
    () => SupervisorUnitsRemoteDs(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<SupervisorUnitsRepo>(
    () => SupervisorUnitsRepoImpl(getIt<SupervisorUnitsRemoteDs>()),
  );
  getIt.registerFactory<SupervisorUnitsCubit>(
    () => SupervisorUnitsCubit(repo: getIt<SupervisorUnitsRepo>()),
  );
  getIt.registerLazySingleton<SupervisorReportsRemoteDs>(
    () => SupervisorReportsRemoteDs(getIt<SupabaseService>(), getIt<UserRemoteDs>()),
  );
  getIt.registerLazySingleton<SupervisorReportsRepo>(
    () => SupervisorReportsRepoImpl(getIt<SupervisorReportsRemoteDs>()),
  );
  getIt.registerFactory<SupervisorReportsCubit>(
    () => SupervisorReportsCubit(
      repo: getIt<SupervisorReportsRepo>(),
      userService: getIt<UserService>(),
    ),
  );
  getIt.registerFactory<SupervisorProfileCubit>(
    () => SupervisorProfileCubit(
      userService: getIt<UserService>(),
      supabaseService: getIt<SupabaseService>(),
    ),
  );
  getIt.registerLazySingleton<SupervisorAddReportRemoteDs>(
    () => SupervisorAddReportRemoteDs(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<SupervisorAddReportRepo>(
    () => SupervisorAddReportRepoImpl(getIt<SupervisorAddReportRemoteDs>()),
  );
  getIt.registerFactory<SupervisorAddReportCubit>(
    () => SupervisorAddReportCubit(
      repo: getIt<SupervisorAddReportRepo>(),
      userService: getIt<UserService>(),
    ),
  );

  // === ADMIN REPORTS ===
  getIt.registerFactory<AdminReportsCubit>(
    () => AdminReportsCubit(
      reportRepo: getIt<ReportRepo>(),
      userService: getIt<UserService>(),
      userRemoteDs: getIt<UserRemoteDs>(),
    ),
  );

  // === SERVICE REQUESTS (Admin) ===
  getIt.registerLazySingleton<ServiceRequestRemoteDs>(
    () => ServiceRequestRemoteDs(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<ServiceRequestRepo>(
    () => ServiceRequestRepoImpl(getIt<ServiceRequestRemoteDs>()),
  );
  getIt.registerFactory<ServiceRequestCubit>(
    () => ServiceRequestCubit(
      getIt<ServiceRequestRepo>(),
      getIt<ServiceTypeRepo>(),
      getIt<UserService>(),
    ),
  );

  // === NOTIFICATIONS ===
  getIt.registerLazySingleton<NotificationRemoteDs>(
    () => NotificationRemoteDs(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<NotificationRepo>(
    () => NotificationRepoImpl(getIt<NotificationRemoteDs>()),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(getIt<NotificationRepo>()),
  );
}
