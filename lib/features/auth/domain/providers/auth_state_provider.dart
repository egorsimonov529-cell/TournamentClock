import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/auth_exception.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../models/auth_state.dart';
import '../repositories/auth_repository.dart';

// ============================================================================
// Провайдеры зависимостей (singleton)
// ============================================================================

/// ApiService (singleton)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// SecureStorageService (singleton)
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// SharedPrefsService (singleton)
final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  return SharedPrefsService();
});

/// AuthRepository (singleton, зависит от сервисов)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiService: ref.watch(apiServiceProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
    sharedPrefs: ref.watch(sharedPrefsServiceProvider),
  );
});

// ============================================================================
// Провайдер состояния авторизации
// ============================================================================

/// Провайдер состояния авторизации
/// Управляет всем процессом: login, logout, refresh token, auto-login
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  final notifier = AuthStateNotifier(
    repository: ref.read(authRepositoryProvider),
  );

  // При инициализации проверяем сохранённую сессию
  Future.microtask(() => notifier.checkInitialSession());

  return notifier;
});

/// StateNotifier для управления состоянием авторизации
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthStateNotifier({required AuthRepository repository})
    : _repository = repository,
      super(const AuthState());

  /// Проверка начальной сессии (при запуске приложения)
  Future<void> checkInitialSession() async {
    try {
      final user = await _repository.checkSession();
      if (user != null) {
        // Сессия активна — определяем роль из сохраненных данных
        String? role;
        final userData = await _repository.getCurrentUser();
        if (userData != null) {
          role = userData.role;
        }
        state = AuthState(
          status: AuthStatus.authenticated,
          message: 'Session verified',
          userRole: role ?? 'admin',
        );
        return;
      }

      // Пробуем auto-login
      final authResponse = await _repository.autoLogin();
      if (authResponse != null) {
        final userData = await _repository.getCurrentUser();
        state = AuthState(
          status: AuthStatus.authenticated,
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          userRole: userData?.role ?? 'admin',
        );
      }
      // Если auto-login не удался — остаемся на initial
    } catch (e) {
      // Игнорируем ошибки при initial check
    }
  }

  /// Вход в систему
  Future<bool> login({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const AuthState(status: AuthStatus.authenticating);

    try {
      final response = await _repository.login(
        login: login,
        password: password,
        rememberMe: rememberMe,
      );

      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userRole: response.user.role,
      );

      return true;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, message: e.message);
      return false;
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        message: 'Неизвестная ошибка',
      );
      return false;
    }
  }

  /// Выход из системы
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    state = const AuthState(status: AuthStatus.authenticating);
    try {
      final response = await _repository.register(
        name: name,
        email: email,
        password: password,
        acceptedTerms: acceptedTerms,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userRole: 'player',
      );
      return true;
    } on AuthException catch (error) {
      state = AuthState(status: AuthStatus.error, message: error.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        message: '╨Э╨╡╨╕╨╖╨▓╨╡╤Б╤В╨╜╨░╤П ╨╛╤И╨╕╨▒╨║╨░',
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.authenticating);
    try {
      final response = await _repository.signInWithGoogle();
      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userRole: response.user.role,
      );
      return true;
    } on AuthException catch (error) {
      state = AuthState(status: AuthStatus.error, message: error.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        message: 'Google-╨▓╤Е╨╛╨┤ ╤В╤А╨╡╨▒╤Г╨╡╤В ╨╜╨░╤Б╤В╤А╨╛╨╣╨║╨╕ OAuth',
      );
      return false;
    }
  }

  /// ╨Т╤Л╤Е╨╛╨┤ ╨╕╨╖ ╤Б╨╕╤Б╤В╨╡╨╝╤Л
  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.loggingOut);

    try {
      await _repository.logout();
    } catch (e) {
      // Игнорируем ошибки при logout
    } finally {
      state = const AuthState();
    }
  }

  /// Получить текущего пользователя
  Future<User?> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }

  /// Проверка авторизации
  bool isAuthenticated() {
    return state.status == AuthStatus.authenticated;
  }

  /// Получить сообщение об ошибке (если есть)
  String? getErrorMessage() {
    return state.message;
  }

  /// Проверка, идет ли процесс авторизации
  bool isAuthenticating() {
    return state.status == AuthStatus.authenticating;
  }
}

/// Current local-demo user shared by player features.
final currentAuthUserProvider = FutureProvider<User?>((ref) async {
  ref.watch(authStateProvider);
  return ref.read(authRepositoryProvider).getCurrentUser();
});
