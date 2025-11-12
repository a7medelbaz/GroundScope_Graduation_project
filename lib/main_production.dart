import 'package:flutter/material.dart';

import 'core/di/dependency_injection.dart';
import 'core/router/app_routers.dart';
import 'ground_scope_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  runApp(GroundScopeApp(appRouter: AppRouter()));
}
// flutter run --release --flavor production --target lib/main_production.dart