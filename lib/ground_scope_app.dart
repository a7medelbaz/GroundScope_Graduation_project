import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/auth/logic/cubit/auth_cubit.dart';
import 'core/auth/ui/user_authenticated_check.dart';
import 'core/config/app_config.dart';
import 'core/di/dependency_injection.dart';
import 'core/router/app_routers.dart';
import 'core/settings/cubit/app_settings_cubit.dart';
import 'core/settings/cubit/app_settings_state.dart';
import 'core/themes/theme_data/theme_data_dark.dart';
import 'core/themes/theme_data/theme_data_light.dart';

class GroundScopeApp extends StatelessWidget {
  const GroundScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (final context, final child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AppSettingsCubit()),
            BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
          ],
          child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder:
                (final BuildContext context, final AppSettingsState settings) {
                  return BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return MaterialApp(
                        key: ValueKey(state is AuthSuccess),
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        locale: settings.locale,
                        debugShowCheckedModeBanner: false,
                        onGenerateRoute: AppRouter.generateRoute,
                        title: AppConfig.appName,
                        theme: getLightTheme().copyWith(
                          textTheme: getLightTheme().textTheme.apply(
                            fontFamily: settings.fontFamily,
                          ),
                        ),
                        darkTheme: getDarkTheme().copyWith(
                          textTheme: getDarkTheme().textTheme.apply(
                            fontFamily: settings.fontFamily,
                          ),
                        ),
                        themeMode: settings.themeMode,
                        home: const UserAuthenticatedCheck(),
                      );
                    },
                  );
                },
          ),
        );
      },
    );
  }
}

// um_fuel@airport.com → UM123456#
