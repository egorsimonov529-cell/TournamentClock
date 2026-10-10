import 'package:flutter/foundation.dart';

enum BackendMode {
  demo,
  mock,
  remote,
}

class AppConfig {
  const AppConfig._();

  static const BackendMode backendMode = BackendMode.remote;
  static const bool useDemoAuth = false;

  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:4000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://172.20.10.3:4000/api/v1';
    // Для iOS замени '192.168.X.X' на свой локальный IP (ipconfig -> IPv4)
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'http://192.168.1.11:4000/api/v1';
    return 'http://localhost:4000/api/v1';
  }

  static String get apiBaseUrl {
    final envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return _defaultBaseUrl;
  }

  static bool get isDemoMode => backendMode == BackendMode.demo || useDemoAuth;
}
