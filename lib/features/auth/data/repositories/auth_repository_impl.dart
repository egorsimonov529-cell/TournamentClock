import 'dart:convert';

import '../../../../core/models/auth_exception.dart';
import '../../../../core/models/auth_response.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../domain/repositories/auth_repository.dart';

/// Реализация репозитория авторизации
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;
  final SharedPrefsService _sharedPrefs;
  final bool isDemoMode;

  AuthRepositoryImpl({
    required ApiService apiService,
    required SecureStorageService secureStorage,
    required SharedPrefsService sharedPrefs,
    this.isDemoMode = true, // Демо-режим включен по умолчанию
  })  : _apiService = apiService,
        _secureStorage = secureStorage,
        _sharedPrefs = sharedPrefs;

  @override
  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async {
    // Демо-режим: любой логин/пароль работают
    if (isDemoMode) {
      // Определяем роль по логину
      final role = login.contains('admin') ? 'admin' : 'player';

      final authResponse = AuthResponse(
        accessToken: 'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'demo_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: User(
          id: role == 'admin' ? 'admin-001' : 'player-001',
          login: login,
          email: '$login@pokerclub.demo',
          role: role,
          firstName: role == 'admin' ? 'Админ' : 'Игрок',
          lastName: 'Пользователь',
          isActive: true,
        ),
      );

      // Сохраняем токены и данные пользователя (с обработкой ошибок)
      try {
        await _secureStorage.write(key: 'access_token', value: authResponse.accessToken);
        await _secureStorage.write(key: 'refresh_token', value: authResponse.refreshToken);
        await _secureStorage.write(key: 'user_data', value: jsonEncode(authResponse.user.toJson()));
        await _secureStorage.write(key: 'user_role', value: role);
      } catch (e) {
        // SecureStorage может не работать на Windows в debug режиме
      }

      // Если "Запомнить меня" — сохраняем логин
      if (rememberMe) {
        await _sharedPrefs.setString('saved_login', login);
      } else {
        await _sharedPrefs.remove('saved_login');
      }

      return authResponse;
    }

    try {
      final response = await _apiService.post('/auth/login', data: {
        'login': login,
        'password': password,
        'remember_me': rememberMe,
      });

      final authResponse = AuthResponse.fromJson(response.data);

      // Сохраняем токены в secure storage
      await _secureStorage.write(
        key: 'access_token',
        value: authResponse.accessToken,
      );
      await _secureStorage.write(
        key: 'refresh_token',
        value: authResponse.refreshToken,
      );

      // Если "Запомнить меня" — сохраняем логин
      if (rememberMe) {
        await _sharedPrefs.setString('saved_login', login);
      } else {
        await _sharedPrefs.remove('saved_login');
      }

      return authResponse;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw const NetworkException();
    }
  }

  @override
  Future<AuthResponse> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiService.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      final authResponse = AuthResponse.fromJson(response.data);

      // Обновляем токены в secure storage
      await _secureStorage.write(
        key: 'access_token',
        value: authResponse.accessToken,
      );
      await _secureStorage.write(
        key: 'refresh_token',
        value: authResponse.refreshToken,
      );

      return authResponse;
    } on AuthException {
      // Если refresh токен тоже истёк — очищаем всё
      await clearAll();
      throw const TokenException();
    } catch (e) {
      await clearAll();
      throw const NetworkException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Отправляем запрос на logout (токен уже в headers)
      await _apiService.postLogout('/auth/logout');
    } catch (e) {
      // Игнорируем ошибки при logout — всё равно очищаем локально
    } finally {
      await clearAll();
    }
  }

  @override
  Future<User?> checkSession() async {
    try {
      final token = await _secureStorage.read('access_token');
      if (token == null || token.isEmpty) {
        return null;
      }

      // В демо-режиме checkSession всегда возвращает null
      // Роль определяется строго при login, чтобы не было конфликтов
      if (isDemoMode) {
        return null;
      }

      // Можно проверить валидность токена запросом к серверу
      return null;
    } catch (e) {
      await clearAll();
      return null;
    }
  }

  @override
  Future<AuthResponse?> autoLogin() async {
    try {
      final accessToken = await _secureStorage.read('access_token');
      final refreshToken = await _secureStorage.read('refresh_token');

      if (accessToken == null || refreshToken == null) {
        return null;
      }

      // Пытаемся обновить токен
      return await this.refreshToken(refreshToken: refreshToken);
    } catch (e) {
      await clearAll();
      return null;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _secureStorage.read('user_data');
      if (userData == null) {
        return null;
      }

      return User.fromJson(jsonDecode(userData) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.delete('access_token');
    await _secureStorage.delete('refresh_token');
    await _secureStorage.delete('user_data');

    // Не удаляем saved_login — он нужен для auto-fill
  }
}
