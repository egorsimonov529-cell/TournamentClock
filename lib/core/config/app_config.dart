enum BackendMode {
  demo,
  mock,
  remote,
}

class AppConfig {
  const AppConfig._();

  static const BackendMode backendMode = BackendMode.remote;
  static const bool useDemoAuth = false;
  static const String apiBaseUrl = 'http://localhost:4000/api/v1';

  static bool get isDemoMode => backendMode == BackendMode.demo || useDemoAuth;
}
