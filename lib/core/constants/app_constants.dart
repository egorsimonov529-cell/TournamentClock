import '../config/app_config.dart';

/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static String get apiBaseUrl => AppConfig.apiBaseUrl;
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;

  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';
  static const String rememberMeKey = 'auth_remember_me';
  static const String savedLoginKey = 'auth_saved_login';
  static const String demoSessionUserKey = 'auth_demo_session_user';
}
