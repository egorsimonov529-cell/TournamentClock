import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager_plus/window_manager_plus.dart';

import 'app/app.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/services/window_manager_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация window_manager с ID окна
  final windowId = args.isEmpty ? 0 : int.tryParse(args[0]) ?? 0;
  await WindowManagerPlus.ensureInitialized(windowId);
  
  await WindowManagerService.init(windowId);
  
  // Инициализация сервисов хранения
  await SecureStorageService().init();
  await SharedPrefsService().init();

  runApp(
    ProviderScope(
      child: const PokerClubApp(),
    ),
  );
}
