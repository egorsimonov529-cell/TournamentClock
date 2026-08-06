/// Константы приложения
class AppConstants {
  AppConstants._();

  /// Базовый URL API
  static const String apiBaseUrl = 'https://api.pokerclub.erm/api';

  /// Таймаут подключения (секунды)
  static const int connectTimeout = 30;

  /// Таймаут получения ответа (секунды)
  static const int receiveTimeout = 30;

  /// Ключ для токена в secure storage
  static const String accessTokenKey = 'auth_access_token';

  /// Ключ для refresh токена в secure storage
  static const String refreshTokenKey = 'auth_refresh_token';

  /// Ключ для запоминания пользователя в shared preferences
  static const String rememberMeKey = 'auth_remember_me';

  /// Ключ для сохранённого логина в shared preferences
  static const String savedLoginKey = 'auth_saved_login';
}
