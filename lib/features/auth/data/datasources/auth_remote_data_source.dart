import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/auth_exception.dart';
import '../../../../core/models/auth_response.dart';
import '../../../../core/models/user.dart';
import '../../../../core/network/club_api_client.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/shared_prefs_service.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  });

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  });

  Future<AuthResponse> refreshToken({required String refreshToken});

  Future<void> logout();

  Future<User?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;
  final SharedPrefsService _sharedPrefs;
  final ClubApiClient _apiClient;

  const AuthRemoteDataSourceImpl({
    required ApiService apiService,
    required SecureStorageService secureStorage,
    required SharedPrefsService sharedPrefs,
    ClubApiClient? apiClient,
  }) : _apiService = apiService,
       _secureStorage = secureStorage,
       _sharedPrefs = sharedPrefs,
       _apiClient = apiClient ?? ClubApiClient(apiService);

  @override
  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final auth = await _apiClient.login(
        login: login,
        password: password,
        rememberMe: rememberMe,
      );
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: auth.accessToken,
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: auth.refreshToken,
      );
      await _secureStorage.write(
        key: AppConstants.demoSessionUserKey,
        value: jsonEncode(auth.user.toJson()),
      );
      await _sharedPrefs.setBool(AppConstants.rememberMeKey, rememberMe);
      if (rememberMe) {
        await _sharedPrefs.setString(AppConstants.savedLoginKey, login);
      } else {
        await _sharedPrefs.remove(AppConstants.savedLoginKey);
      }

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
      final auth = await _apiClient.register(
        name: name,
        email: email,
        password: password,
      );

      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: auth.accessToken,
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: auth.refreshToken,
      );
      await _secureStorage.write(
        key: AppConstants.demoSessionUserKey,
        value: jsonEncode(auth.user.toJson()),
      );
      await _sharedPrefs.setBool(AppConstants.rememberMeKey, true);
      await _sharedPrefs.setString(AppConstants.savedLoginKey, auth.user.login);

      return auth;
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  @override
  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    try {
      final auth = await _apiClient.refreshToken(refreshToken: refreshToken);
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
      throw const TokenException();
    } catch (_) {
      throw const NetworkException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } catch (_) {
      // ignore server-side logout failure and continue local clear
    }
    await _secureStorage.delete(AppConstants.accessTokenKey);
    await _secureStorage.delete(AppConstants.refreshTokenKey);
    await _secureStorage.delete(AppConstants.demoSessionUserKey);
    await _sharedPrefs.remove(AppConstants.rememberMeKey);
    await _sharedPrefs.remove(AppConstants.savedLoginKey);
    await _sharedPrefs.remove(AppConstants.demoSessionUserKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final data = await _secureStorage.read(AppConstants.demoSessionUserKey);
    if (data == null || data.isEmpty) return null;

    try {
      return User.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
