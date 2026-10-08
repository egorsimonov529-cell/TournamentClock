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
    // VPS сервер
    const vpsHost = String.fromEnvironment('VPS_HOST', defaultValue: '188.225.81.114');
    if (vpsHost.isNotEmpty) {
      return 'http://$vpsHost:4000/api/v1';
    }
    
    if (kIsWeb) return 'http://localhost:4000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:4000/api/v1';
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
