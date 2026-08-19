import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager_plus/window_manager_plus.dart';

import '../../features/tournament_clock/presentation/screens/tournament_clock_window.dart';

class WindowManagerService {
  static WindowManagerPlus? _clockWindowManager;

  /// Размер окна с таймером
  static const _clockWindowSize = Size(1280, 720);
  static const _clockWindowMinSize = Size(1024, 600);
  static const _clockWindowTitle = 'Tournament Clock';

  /// Размер главного окна
  static const _mainWindowSize = Size(1440, 900);
  static const _mainWindowMinSize = Size(1024, 768);

  /// Инициализация window_manager для главного окна (ID = 0)
  static Future<void> init(int windowId) async {
    if (windowId == 0) {
      // Главное окно — убираем заголовок
      await WindowManagerPlus.current.setSize(_mainWindowSize);
      await WindowManagerPlus.current.setMinimumSize(_mainWindowMinSize);
      await WindowManagerPlus.current.setAlignment(Alignment.center);
      await WindowManagerPlus.current.setTitleBarStyle(TitleBarStyle.hidden);
      await WindowManagerPlus.current.show();
      await WindowManagerPlus.current.focus();
    }
  }

  /// Открыть окно с таймером
  static Future<void> openClockWindow() async {
    if (_clockWindowManager != null) {
      // Если окно уже открыто — просто фокусируем
      await _clockWindowManager!.show();
      await _clockWindowManager!.focus();
      return;
    }

    // Создаём новое окно
    _clockWindowManager = await WindowManagerPlus.createWindow(['clock']);
    
    if (_clockWindowManager == null) {
      debugPrint('Failed to create clock window');
      return;
    }

    // Настраиваем новое окно
    await _clockWindowManager!.setSize(_clockWindowSize);
    await _clockWindowManager!.setMinimumSize(_clockWindowMinSize);
    await _clockWindowManager!.setTitle(_clockWindowTitle);
    await _clockWindowManager!.setAsFrameless();
    await _clockWindowManager!.setBackgroundColor(Colors.black);
    await _clockWindowManager!.center();

    // Запускаем Flutter app для нового окна
    runApp(
      ProviderScope(
        child: ClockWindowWidget(windowManager: _clockWindowManager!),
      ),
    );

    await _clockWindowManager!.show();
    await _clockWindowManager!.focus();
  }

  /// Закрыть окно с таймером
  static Future<void> closeClockWindow() async {
    if (_clockWindowManager != null) {
      await _clockWindowManager!.close();
      _clockWindowManager = null;
    }
  }
}
