import 'package:ground_scope/core/config/app_config.dart';

class AppConstants {
  AppConstants._();

  /// Read from .env — never hardcode the key here.
  static String get aviationStackKey => AppConfig.aviationStackKey;
  static String get airLabsApiKey => AppConfig.airLabsApiKey;
  static const String airportIataCode = 'CAI';
}
