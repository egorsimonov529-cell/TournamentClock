/// Базовый класс исключений авторизации
abstract class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});
}

/// Ошибка сети (нет соединения, таймаут и т.д.)
class NetworkException extends AuthException {
  const NetworkException({
    super.message = 'Ошибка сетевого подключения. Проверьте интернет.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Ошибка неавторизации (неверные учётные данные)
class UnauthorizedException extends AuthException {
  const UnauthorizedException({
    super.message = 'Неверный логин или пароль',
    super.code = 'UNAUTHORIZED',
  });
}

/// Ошибка токена (истёк, невалидный)
class TokenException extends AuthException {
  const TokenException({
    super.message = 'Ошибка авторизации. Войдите в систему снова.',
    super.code = 'TOKEN_ERROR',
  });
}

/// Ошибка сервера (5xx)
class ServerException extends AuthException {
  const ServerException({
    super.message = 'Ошибка сервера. Попробуйте позже.',
    super.code = 'SERVER_ERROR',
  });
}

/// Конфликт данных (например, уже зарегистрированный email / логин)
class ConflictException extends AuthException {
  const ConflictException({
    super.message = 'Такой аккаунт уже существует. Попробуйте другой email или имя.',
    super.code = 'CONFLICT',
  });
}

/// Ошибка валидации данных
class ValidationException extends AuthException {
  const ValidationException({
    super.message = 'Ошибка валидации данных',
    super.code = 'VALIDATION_ERROR',
    required this.fieldErrors,
  });

  final Map<String, String> fieldErrors;
}

/// Ошибка блокировки (аккаунт заблокирован)
class AccountLockedException extends AuthException {
  const AccountLockedException({
    super.message = 'Аккаунт заблокирован. Обратитесь к администратору.',
    super.code = 'ACCOUNT_LOCKED',
  });
}

/// Google OAuth ещё не настроен для production-окружения.
class OAuthUnavailableException extends AuthException {
  const OAuthUnavailableException({
    super.message = 'Google-вход требует настройки OAuth',
    super.code = 'OAUTH_UNAVAILABLE',
  });
}
