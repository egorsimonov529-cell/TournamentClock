import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Перечисление доступных тем
enum AppThemeType {
  gold('Золото', 'Классическая казино-тематика'),
  emerald('Изумруд', 'Современная технологичная тема');

  final String label;
  final String description;
  const AppThemeType(this.label, this.description);
}

/// Провайдер темы — управляет переключением между золотом и изумрудом
class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier() : super(AppThemeType.emerald);

  void toggleTheme() {
    state = state == AppThemeType.gold
        ? AppThemeType.emerald
        : AppThemeType.gold;
  }

  void setTheme(AppThemeType theme) {
    state = theme;
  }
}

/// Провайдер текущей темы
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});

/// Расширение для получения цветов в зависимости от темы
extension AppThemeColors on AppThemeType {
  /// Основной цвет (золотой или изумрудный)
  Color get primaryColor {
    switch (this) {
      case AppThemeType.gold:
        return const Color(0xffB8860B);
      case AppThemeType.emerald:
        return const Color(0xff059669);
    }
  }

  /// Светлый вариант основного цвета
  Color get primaryLight {
    switch (this) {
      case AppThemeType.gold:
        return const Color(0xffDAA520);
      case AppThemeType.emerald:
        return const Color(0xff10B981);
    }
  }

  /// Яркий акцент
  Color get accent {
    switch (this) {
      case AppThemeType.gold:
        return const Color(0xffFFD700);
      case AppThemeType.emerald:
        return const Color(0xff34D399);
    }
  }

  /// Премиум-акцент (приглушённый)
  Color get gold {
    switch (this) {
      case AppThemeType.gold:
        return const Color(0xffC9A84E);
      case AppThemeType.emerald:
        return const Color(0xff047857);
    }
  }

  /// Светлый премиум-акцент
  Color get goldLight {
    switch (this) {
      case AppThemeType.gold:
        return const Color(0xffE8C547);
      case AppThemeType.emerald:
        return const Color(0xff6EE7B7);
    }
  }

  /// Цвет бордеров
  Color get borderColor {
    switch (this) {
      case AppThemeType.gold:
        return const Color(0xffC9A84E);
      case AppThemeType.emerald:
        return const Color(0xff10B981);
    }
  }

  /// Цвет карточки при наведении
  Color get cardHover {
    switch (this) {
      case AppThemeType.gold:
        return const Color(0xff2A2318);
      case AppThemeType.emerald:
        return const Color(0xff1A2E23);
    }
  }

  /// Цвет бордера карточки
  Color get cardBorder {
    switch (this) {
      case AppThemeType.gold:
        return const Color(0xff3D3220);
      case AppThemeType.emerald:
        return const Color(0xff2A4A35);
    }
  }
}
