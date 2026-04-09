import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

class AppConfig {
  AppConfig._();
  static const String supaBaseUr = 'https://xegigwfjsxwpmgqyhijf.supabase.co';
  static const String supaBaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlZ2lnd2Zqc3h3cG1ncXloaWpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0MDI3ODgsImV4cCI6MjA5MDk3ODc4OH0.QSLdKZqApJHeFusMH5mpYkHlL24sh1SvTlZZZm-tDKk';

  // App Version
  static const String appVersion = '1.0.0';
}

Future<void> setupHydratedStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
}
