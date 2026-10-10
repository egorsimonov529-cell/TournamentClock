import 'package:flutter/services.dart';

class WindowManagerService {
  static Future<void> minimizeWindow() async {}

  static Future<void> closeApplication() => SystemNavigator.pop();
}
