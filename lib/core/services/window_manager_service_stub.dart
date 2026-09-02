import 'package:flutter/services.dart';

class WindowManagerService {
  static Future<void> openClockWindow() async {}

  static Future<void> closeClockWindow() async {}

  static Future<void> minimizeWindow() async {}

  static Future<void> closeApplication() => SystemNavigator.pop();
}
