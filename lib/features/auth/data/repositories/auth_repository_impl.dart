import 'dart:convert';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/auth_exception.dart';
import '../../../../core/models/auth_response.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../domain/models/demo_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository_contract.dart';

class AuthRepositoryImpl implements AuthRepository, AuthRepositoryContract {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;
  final SharedPrefsService _sharedPrefs;
  final bool isDemoMode;

  AuthRepositoryImpl({
    required ApiService apiService,
    required SecureStorageService secureStorage,
    required SharedPrefsService sharedPrefs,
    this.isDemoMode = AppConfig.useDemoAuth,
  }) : _apiService = apiService,
       _secureStorage = secureStorage,
       _sharedPrefs = sharedPrefs;

  Future<void> _persistSession(User user, bool rememberMe) async {
    await _secureStorage.write(
      key: AppConstants.demoSessionUserKey,
      value: jsonEncode(user.toJson()),
    );
    await _sharedPrefs.setBool(AppConstants.rememberMeKey, rememberMe);
    if (rememberMe) {
      await _sharedPrefs.setString(AppConstants.savedLoginKey, user.login);
    } else {
      await _sharedPrefs.remove(AppConstants.savedLoginKey);
    }
  }

  @override
  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'login': login, 'password': password, 'remember_me': rememberMe},
      );
      final auth = AuthResponse.fromJson(response.data);
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: auth.accessToken,
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: auth.refreshToken,
      );
      await _persistSession(auth.user, rememberMe);
      return auth;
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    if (!acceptedTerms) {
      throw const ValidationException(
        message: 'Необходимо согласие с правилами',
        fieldErrors: {'acceptedTerms': 'Необходимо согласие'},
      );
    }
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      final auth = AuthResponse.fromJson(response.data);
      await _persistSession(auth.user, true);
      return auth;
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  @override
  Future<AuthResponse> signInWithGoogle() =>
      throw const OAuthUnavailableException();

  @override
  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    if (isDemoMode) throw const TokenException();
    try {
      final response = await _apiService.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final auth = AuthResponse.fromJson(response.data);
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: auth.accessToken,
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: auth.refreshToken,
      );
      return auth;
    } on AuthException {
      await clearAll();
      throw const TokenException();
    } catch (_) {
      await clearAll();
      throw const NetworkException();
    }
  }

  @override
  Future<DemoSession> restoreSession() async {
    final user = await checkSession();
    return user == null
        ? const DemoSession.anonymous()
        : DemoSession.authenticated(user);
  }

  @override
  Future<void> logout() async {
    if (!isDemoMode) {
      try {
        await _apiService.postLogout('/auth/logout');
      } catch (_) {}
    }
    await clearAll();
  }

  @override
  Future<User?> checkSession() async {
    final token = await _secureStorage.read(AppConstants.accessTokenKey);
    return token == null || token.isEmpty ? null : getCurrentUser();
  }

  @override
  Future<AuthResponse?> autoLogin() async {
    final user = await getCurrentUser();
    if (user == null) return null;

    final token = await _secureStorage.read(AppConstants.accessTokenKey);
    final refreshToken = await _secureStorage.read(AppConstants.refreshTokenKey);
    if ((token == null || token.isEmpty) || (refreshToken == null || refreshToken.isEmpty)) {
      return null;
    }

    return AuthResponse(
      accessToken: token,
      refreshToken: refreshToken,
      user: user,
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    if (isDemoMode) {
      await _sharedPrefs.init();
      final data = _sharedPrefs.getString(AppConstants.demoSessionUserKey);
      if (data == null) return null;
      try {
        return User.fromJson(jsonDecode(data) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }

    final data = await _secureStorage.read(AppConstants.demoSessionUserKey);
    if (data == null) return null;
    try {
      return User.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.delete(AppConstants.accessTokenKey);
    await _secureStorage.delete(AppConstants.refreshTokenKey);
    await _secureStorage.delete(AppConstants.demoSessionUserKey);
    await _sharedPrefs.remove(AppConstants.rememberMeKey);
    await _sharedPrefs.remove(AppConstants.savedLoginKey);
    await _sharedPrefs.remove(AppConstants.demoSessionUserKey);
  }
}
