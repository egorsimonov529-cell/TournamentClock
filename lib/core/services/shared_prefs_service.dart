import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для хранения простых данных (настройки, сохранённый логин)
class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  SharedPreferences? _prefs;

  /// Инициализация
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Установить строковое значение
  Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }

  /// Получить строковое значение
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Установить bool значение
  Future<bool> setBool(String key, bool value) async {
    await init();
    return await _prefs!.setBool(key, value);
  }

  /// Получить bool значение
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Удалить значение
  Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }

  /// Проверить наличие ключа
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Очистить всё
  Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }
}
