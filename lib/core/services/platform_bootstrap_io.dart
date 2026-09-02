import 'dart:io';

import 'window_manager_service_io.dart';

Future<void> initializePlatform(List<String> args) async {
  if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;

  final windowId = args.isEmpty ? 0 : int.tryParse(args.first) ?? 0;
  await WindowManagerService.initialize(windowId);
}
