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
    if (kIsWeb) return 'http://188.225.81.114:4000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://188.225.81.114:4000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'http://188.225.81.114:4000/api/v1';
    return 'http://188.225.81.114:4000/api/v1';
  }

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    return _defaultBaseUrl;
  }

  static bool get isDemoMode => backendMode == BackendMode.demo || useDemoAuth;
}
