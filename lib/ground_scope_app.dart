import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/auth/logic/cubit/auth_cubit.dart';
import 'core/auth/ui/user_authenticated_check.dart';
import 'core/di/dependency_injection.dart';
import 'core/themes/cubit/theme_cubit.dart';
import 'core/themes/theme_data/theme_data_dark.dart';
import 'core/themes/theme_data/theme_data_light.dart';

import 'core/router/app_routers.dart';

class GroundScopeApp extends StatelessWidget {
  const GroundScopeApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (final context, final child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (final context, final mode) {
              // FlutterNativeSplash.remove();
              return MaterialApp(
                key: ValueKey(context.locale),
                debugShowCheckedModeBanner: false,
                title: 'GroundScope',
                home: const UserAuthenticatedCheck(),
                onGenerateRoute: appRouter.generateRoute,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: getLightTheme(context: context),
                darkTheme: getDarkTheme(context: context),
                themeMode: mode,
              );
            },
          ),
        );
      },
    );
  }
}
