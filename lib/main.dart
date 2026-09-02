import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/platform_bootstrap.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/shared_prefs_service.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializePlatform(args);
  await SecureStorageService().init();
  await SharedPrefsService().init();

  runApp(const ProviderScope(child: PokerClubApp()));
}
