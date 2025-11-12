import 'package:flutter/material.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/router/app_routers.dart';
import 'package:ground_scope/ground_scope_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  runApp(GroundScopeApp(appRouter: AppRouter()));
}
// flutter run --release --flavor production --target lib/main_production.dart