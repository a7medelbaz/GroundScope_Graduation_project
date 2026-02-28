import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

class AppConfig {
  AppConfig._();
  static const String supaBaseUr = 'https://bmfsoaduxasmlpkdyzji.supabase.co';
  static const String supaBaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJtZnNvYWR1eGFzbWxwa2R5emppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MzgxMzAsImV4cCI6MjA3ODUxNDEzMH0.Y3pODH_C9L1HGEFYTj_0FNPuQaUeZntlK4ROUVk7-tA';

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
