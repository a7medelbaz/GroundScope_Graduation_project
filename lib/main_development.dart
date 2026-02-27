import 'package:flutter/material.dart';
import 'package:ground_scope/core/config/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/onboarding/ui/on_boarding_screen.dart';
import 'core/router/app_routers.dart';
import 'core/utils/secure_storage.dart';
import 'ground_scope_app.dart';
import 'modules/admin/features/home/admin_screen.dart';
import 'modules/supervisor/features/home/supervisor_screen.dart';
import 'modules/worker/core/widgets/worker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConstants.supaBaseUr,
    anonKey: AppConstants.supaBaseKey,
  );
  await setupGetIt();

  final storage = SecureStorage();
  final cachedRole = await storage.getString(key: 'position');

  Widget initialScreen = const OnBoardingScreen();

  if (cachedRole == 'worker') {
    initialScreen = const WorkerScreen();
  } else if (cachedRole == 'supervisor') {
    initialScreen = const SupervisorScreen();
  } else if (cachedRole == 'admin') {
    initialScreen = const AdminScreen();
  }
  runApp(GroundScopeApp(appRouter: AppRouter(), initialScreen: initialScreen));
}

// flutter run --release --flavor development --target lib/main_development.dart
// flutter build apk --flavor development --target lib/main_development.dart
