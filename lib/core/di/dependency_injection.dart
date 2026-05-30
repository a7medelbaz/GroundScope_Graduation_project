import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ground_scope/core/shared/data/remote/report_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo_impl.dart';
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
import '../../modules/supervisor/features/dashboard/data/remote/supervisor_dashboard_remote_ds.dart';
import '../../modules/supervisor/features/dashboard/data/repo/supervisor_dashboard_repo.dart';
import '../../modules/supervisor/features/dashboard/data/repo/supervisor_dashboard_repo_impl.dart';
import '../../modules/supervisor/features/dashboard/logic/cubit/assign_task_cubit.dart';
import '../../modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart';
import '../../modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart';

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
    ),
  );

  // Reports DI
  getIt.registerFactory<ReportsCubit>(
    () => ReportsCubit(
      reportRepo: getIt<ReportRepo>(),
      userService: getIt<UserService>(),
    ),
  );

  // Supervisor Dashboard DI
  getIt.registerLazySingleton<SupervisorDashboardRemoteDs>(
    () => SupervisorDashboardRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<SupervisorDashboardRepo>(
    () => SupervisorDashboardRepoImpl(remoteDs: getIt<SupervisorDashboardRemoteDs>()),
  );
  getIt.registerFactory<SupervisorDashboardCubit>(
    () => SupervisorDashboardCubit(repo: getIt<SupervisorDashboardRepo>()),
  );
  getIt.registerFactory<SupervisorReportsCubit>(
    () => SupervisorReportsCubit(reportRepo: getIt<ReportRepo>()),
  );
  getIt.registerFactory<AssignTaskCubit>(
    () => AssignTaskCubit(
      repo: getIt<SupervisorDashboardRepo>(),
      userService: getIt<UserService>(),
    ),
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
}
