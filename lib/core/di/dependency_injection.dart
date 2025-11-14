import 'package:get_it/get_it.dart';
import '../auth/data/service/auth_service.dart';
import '../auth/data/repo/auth_repo.dart';
import '../auth/logic/cubit/auth_cubit.dart';

final getIt = GetIt.instance;
Future<void> setupGetIt() async {
  /// Auth DI
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepo(authService: getIt<AuthService>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepo>()),
  );
}
