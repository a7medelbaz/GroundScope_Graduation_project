import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../service/user_service.dart';
import '../shared/data/remote/flights_remote_ds.dart';
import '../shared/data/remote/task_remote_ds.dart';
import '../shared/data/remote/unit_remote_ds.dart';
import '../shared/data/repo/flight_repo.dart';
import '../shared/data/repo/flight_repo_impl.dart';
import '../shared/data/repo/task_repo.dart';
import '../shared/data/repo/task_repo_impl.dart';
import '../shared/data/repo/unit_repo.dart';
import '../shared/data/repo/unit_repo_impl.dart';
import '../../modules/worker/features/task_details/data/remote/task_details_remote_ds.dart';
import '../../modules/worker/features/task_details/data/repo/task_details_repo.dart';
import '../../modules/worker/features/task_details/data/repo/task_details_repo_impl.dart';
import '../../modules/worker/features/task_details/logic/cubit/task_details_cubit.dart';

import '../../modules/worker/features/home/data/remote/home_remote_ds.dart';
import '../../modules/worker/features/home/data/repo/home_repo.dart';
import '../../modules/worker/features/home/data/repo/home_repo_impl.dart';
import '../../modules/worker/features/home/logic/cubit/home_cubit.dart';
import '../auth/data/remote/auth_remote_ds.dart';
import '../auth/data/repo/auth_repo.dart';
import '../auth/data/repo/auth_repo_impl.dart';
import '../auth/logic/cubit/auth_cubit.dart';
import '../networking/supabase_service.dart';
import '../service/secure_storage.dart';

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

  // Home DI
  getIt.registerLazySingleton<HomeRemoteDs>(
    () => HomeRemoteDs(supabaseService: getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<HomeRepo>(
    () => HomeRepoImpl(
      remoteDs: getIt<HomeRemoteDs>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      homeRepo: getIt<HomeRepo>(),
      unitRepo: getIt<UnitRepo>(),
      userService: getIt<UserService>(),
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
}
