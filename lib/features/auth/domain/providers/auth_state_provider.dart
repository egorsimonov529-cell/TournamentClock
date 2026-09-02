import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/auth_exception.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../models/auth_state.dart';
import '../repositories/auth_repository.dart';
import '../usecases/login_usecase.dart';
import '../usecases/register_usecase.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);
final sharedPrefsServiceProvider = Provider<SharedPrefsService>(
  (ref) => SharedPrefsService(),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    apiService: ref.watch(apiServiceProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
    sharedPrefs: ref.watch(sharedPrefsServiceProvider),
    isDemoMode: AppConfig.useDemoAuth,
  ),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.read(authRepositoryProvider)),
);

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier(
    repository: ref.read(authRepositoryProvider),
  );
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthStateNotifier({
    required AuthRepository repository,
    LoginUseCase? loginUseCase,
    RegisterUseCase? registerUseCase,
  }) : _repository = repository,
       _loginUseCase = loginUseCase ?? LoginUseCase(repository),
       _registerUseCase = registerUseCase ?? RegisterUseCase(repository),
       super(const AuthState());

  Future<void> checkInitialSession() async {
    state = const AuthState(status: AuthStatus.initializing);

    try {
      final user = await _repository.getCurrentUser();
      if (user == null) {
        state = const AuthState(status: AuthStatus.anonymous);
        return;
      }

      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.anonymous);
    }
  }

  Future<bool> login({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const AuthState(status: AuthStatus.authenticating);
    try {
      final response = await _loginUseCase(
        login: login,
        password: password,
        rememberMe: rememberMe,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        accessToken: response.accessToken.isEmpty ? null : response.accessToken,
        refreshToken: response.refreshToken.isEmpty
            ? null
            : response.refreshToken,
      );
      return true;
    } on AuthException catch (error) {
      state = AuthState(status: AuthStatus.error, message: error.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        message: 'Неизвестная ошибка',
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    state = const AuthState(status: AuthStatus.authenticating);
    try {
      final response = await _registerUseCase(
        name: name,
        email: email,
        password: password,
        acceptedTerms: acceptedTerms,
      );
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      return true;
    } on AuthException catch (error) {
      state = AuthState(status: AuthStatus.error, message: error.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        message: 'Неизвестная ошибка',
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.authenticating);
    try {
      final response = await _repository.signInWithGoogle();
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      return true;
    } on AuthException catch (error) {
      state = AuthState(status: AuthStatus.error, message: error.message);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.loggingOut);
    try {
      await _repository.logout();
    } finally {
      state = const AuthState(status: AuthStatus.anonymous);
    }
  }

  Future<User?> getCurrentUser() => _repository.getCurrentUser();
  bool isAuthenticated() => state.isAuthenticated;
  String? getErrorMessage() => state.message;
  bool isAuthenticating() => state.status == AuthStatus.authenticating;
}

final currentAuthUserProvider = FutureProvider<User?>((ref) async {
  final authState = ref.watch(authStateProvider);
  // Use in-memory user first — avoids null when rememberMe=false
  if (authState.user != null) return authState.user;
  return ref.read(authRepositoryProvider).getCurrentUser();
});
