import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Сервис для безопасного хранения敏感 данных (токены)
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Записать значение
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Прочитать значение
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Удалить значение
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Очистить всё хранилище
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Проверить наличие ключа
  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null && value.isNotEmpty;
  }
}
