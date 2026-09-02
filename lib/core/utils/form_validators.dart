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

    // Разрешаем буквы (любые языки), цифры, точку, дефис, подчёркивание и @
    // Пробелы не разрешаем (логин не должен содержать пробелы)
    final pattern = r'^[\p{L}\p{N}_.@-]+$';
    final regex = RegExp(pattern, unicode: true);

    if (!regex.hasMatch(value)) {
      return 'Логин может содержать буквы, цифры, пробел, точку, дефис, подчёркивание и @';
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

    // Поддерживаем Unicode-символы в local-part (кириллица), но домен остаётся ASCII
    final pattern = r'^[\p{L}\p{N}._%+-]+@[\p{L}\p{N}-]+\.[\p{L}\p{N}]{2,}$';
    final regex = RegExp(pattern, unicode: true);

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
