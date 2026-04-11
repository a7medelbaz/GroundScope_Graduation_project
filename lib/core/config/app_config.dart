import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

enum Environment { development, production }

class AppConfig {
  AppConfig._();

  // Environment — driven by --dart-define at compile time
  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static Environment get environment =>
      _env == 'production' ? Environment.production : Environment.development;

  static bool get isProduction => environment == Environment.production;
  static bool get isDevelopment => environment == Environment.development;
  static bool get enableLogging => !isProduction;

  // App Info
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'GroundScope',
  );
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Supabase Config
  static const String supaBaseUr = 'https://xegigwfjsxwpmgqyhijf.supabase.co';
  static const String supaBaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlZ2lnd2Zqc3h3cG1ncXloaWpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0MDI3ODgsImV4cCI6MjA5MDk3ODc4OH0.QSLdKZqApJHeFusMH5mpYkHlL24sh1SvTlZZZm-tDKk';

  // Developer Info

  static const String developerName = 'Mustafa Elbaz';
  static const String developerGithub = 'https://github.com/mustafaelbaz5';
  static const String developerProfile =
      'https://mustafa-portfolio-eight.vercel.app/';
  static const String developerLinkedIn =
      'https://www.linkedin.com/in/mustafa-elbaz-725a6631a';
  static const String developerEmail = 'm9stafa05@gmail.com';
}

Future<void> setupHydratedStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
}
