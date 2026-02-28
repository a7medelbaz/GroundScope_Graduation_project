import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

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

  /// Auth DI
  getIt.registerLazySingleton<AuthRemoteDs>(
    () => AuthRemoteDs(
      supabaseService: getIt<SupabaseService>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(authRemoteDs: getIt<AuthRemoteDs>()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));
}
