import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/router/app_routers.dart';
import 'ground_scope_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supaBaseUr,
    anonKey: AppConfig.supaBaseKey,
  );
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    setupHydratedStorage(),
    setUpDependencies(),
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      startLocale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      child: GroundScopeApp(appRouter: AppRouter()),
    ),
  );
}
