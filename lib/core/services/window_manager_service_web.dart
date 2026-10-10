// Web stub — window manager doesn't exist on web
import 'package:flutter/services.dart';

class WindowManagerService {
  static Future<void> minimizeWindow() async {}

  static Future<void> closeApplication() => SystemNavigator.pop();
}
