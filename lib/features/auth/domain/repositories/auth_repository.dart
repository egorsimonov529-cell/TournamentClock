import 'dart:async';

import '../../../../core/models/auth_response.dart';
import '../../../../core/models/user.dart';

/// Интерфейс репозитория авторизации
abstract class AuthRepository {
  /// Войти в систему
  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  });

  /// Обновить токен доступа
  Future<AuthResponse> refreshToken({
    required String refreshToken,
  });

  /// Выйти из системы
  Future<void> logout();

  /// Проверить текущую сессию (валидность токена)
  Future<User?> checkSession();

  /// Автоматически войти при сохранённой сессии
  Future<AuthResponse?> autoLogin();

  /// Получить текущего пользователя
  Future<User?> getCurrentUser();

  /// Очистить все данные
  Future<void> clearAll();
}
