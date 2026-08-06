/// Утилиты для валидации форм
class FormValidators {
  FormValidators._();

  /// Валидация поля логина
  static String? login(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите логин';
    }

    if (value.length < 3) {
      return 'Логин должен содержать минимум 3 символа';
    }

    if (value.length > 50) {
      return 'Логин не должен превышать 50 символов';
    }

    // Разрешаем буквы, цифры, точку, дефис, подчёркивание
    final pattern = r'^[a-zA-Z0-9._-]+$';
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Логин может содержать только буквы, цифры, точку, дефис и подчёркивание';
    }

    return null;
  }

  /// Валидация поля пароля
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }

    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }

    if (value.length > 128) {
      return 'Пароль не должен превышать 128 символов';
    }

    return null;
  }

  /// Валидация email (если используется)
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }

    final pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Введите корректный email';
    }

    return null;
  }

  /// Валидация всего формы входа
  static Map<String, String?> validateLoginForm({
    required String login,
    required String password,
  }) {
    return {
      'login': FormValidators.login(login),
      'password': FormValidators.password(password),
    };
  }
}
