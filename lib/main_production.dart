import 'package:flutter/material.dart';
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
  runApp(GroundScopeApp(appRouter: AppRouter()));
}
// flutter run --release --flavor production --target lib/main_production.dart