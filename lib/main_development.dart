import 'package:flutter/material.dart';
import 'package:ground_scope/core/onboarding/ui/on_boarding_screen.dart';
import 'package:ground_scope/core/utils/secure_storage.dart';
import 'package:ground_scope/modules/admin/features/home/admin_screen.dart';
import 'package:ground_scope/modules/supervisor/features/home/supervisor_screen.dart';
import 'package:ground_scope/modules/worker/features/home/ui/widgets/worker_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/router/app_routers.dart';
import 'ground_scope_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bmfsoaduxasmlpkdyzji.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJtZnNvYWR1eGFzbWxwa2R5emppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MzgxMzAsImV4cCI6MjA3ODUxNDEzMH0.Y3pODH_C9L1HGEFYTj_0FNPuQaUeZntlK4ROUVk7-tA',
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
  runApp(
    GroundScopeApp(
      appRouter: AppRouter(),
      initialScreen: initialScreen,
    ),
  );
}

// flutter run --release --flavor development --target lib/main_development.dart
// flutter build apk --flavor development --target lib/main_development.dart
