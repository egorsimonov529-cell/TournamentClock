import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для безопасного хранения данных (токены).
/// Использует shared_preferences вместо flutter_secure_storage,
/// чтобы избежать зависимости от JNI, которая ломает Android-сборку.
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  SharedPreferences? _prefs;

  /// Инициализация
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Записать значение
  Future<void> write({required String key, required String value}) async {
    await init();
    await _prefs!.setString(key, value);
  }

  /// Прочитать значение
  Future<String?> read(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  /// Удалить значение
  Future<void> delete(String key) async {
    await init();
    await _prefs!.remove(key);
  }

  /// Очистить всё хранилище
  Future<void> deleteAll() async {
    await init();
    await _prefs!.clear();
  }

  /// Проверить наличие ключа
  Future<bool> containsKey(String key) async {
    await init();
    return _prefs!.containsKey(key);
  }
}
