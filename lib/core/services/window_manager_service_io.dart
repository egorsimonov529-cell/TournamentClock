import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager_plus/window_manager_plus.dart';

class WindowManagerService {
  static const _mainWindowSize = Size(1440, 900);
  static const _mainWindowMinSize = Size(1024, 768);

  static bool get _isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  static Future<void> initialize(int windowId) async {
    if (!_isDesktop) return;

    await WindowManagerPlus.ensureInitialized(windowId);
    if (windowId != 0) return;

    await WindowManagerPlus.current.setSize(_mainWindowSize);
    await WindowManagerPlus.current.setMinimumSize(_mainWindowMinSize);
    await WindowManagerPlus.current.setAlignment(Alignment.center);
    await WindowManagerPlus.current.setTitleBarStyle(TitleBarStyle.hidden);
    await WindowManagerPlus.current.show();
    await WindowManagerPlus.current.maximize();
    await WindowManagerPlus.current.focus();
  }

  static Future<void> minimizeWindow() async {
    if (_isDesktop) {
      await WindowManagerPlus.current.minimize();
      return;
    }
  }

  static Future<void> closeApplication() async {
    if (_isDesktop) {
      await WindowManagerPlus.current.destroy();
      return;
    }
    await SystemNavigator.pop();
  }
}
