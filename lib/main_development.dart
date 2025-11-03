import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/router/app_routers.dart';
import 'package:ground_scope/ground_scope_app.dart';

void main() async {
  setupGetIt();
  await ScreenUtil.ensureScreenSize();
  runApp(GroundScopeApp(appRouter: AppRouter()));
}

// flutter run --release --flavor development --target lib/main_development.dart
