import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/auth_exception.dart';
import '../../core/services/secure_storage_service.dart';

/// HTTP-сервис для работы с API
class ApiService {
  late final Dio _dio;
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: AppConstants.connectTimeout),
          receiveTimeout: const Duration(seconds: AppConstants.receiveTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // Добавляем интерцептор для автоматического добавления токена
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Если 401 — пытаемся обновить токен
          if (error.response?.statusCode == 401) {
            final shouldRetry = await _handleUnauthorized(error.requestOptions);
            if (shouldRetry) {
              final retryResponse = await _retryRequest(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Обработка 401: пробуем обновить токен через refresh_token
  Future<bool> _handleUnauthorized(RequestOptions options) async {
    if (_isRefreshing) {
      // Уже обновляем токен — ждём завершения
      final refreshResult = await _refreshCompleter!.future;
      if (refreshResult) {
        final newToken = await _getAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $newToken';
        }
        return true;
      }
      return false;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final success = await refreshToken();
      if (success) {
        // Обновляем токен в заголовках текущего запроса
        final newToken = await _getAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $newToken';
        }
        _refreshCompleter!.complete(true);
        return true;
      } else {
        // Обновление не удалось — очищаем сессию
        await _clearAllTokens();
        _refreshCompleter!.complete(false);
        return false;
      }
    } catch (e) {
      print('Ошибка обновления токена: $e');
      await _clearAllTokens();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Повторный запрос с обновлённым токеном
  Future<Response> _retryRequest(RequestOptions options) async {
    final token = await _getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      cancelToken: options.cancelToken,
      options: Options(
        method: options.method,
        headers: options.headers,
        responseType: options.responseType,
        contentType: options.contentType,
      ),
    );
  }

  /// Обновление access token через refresh token
  Future<bool> refreshToken() async {
    try {
      final storage = SecureStorageService();
      final storedRefreshToken = await storage.read(AppConstants.refreshTokenKey);
      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        print('🔄 Refresh token отсутствует');
        return false;
      }

      print('🔄 Отправка refresh token на сервер...');
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': storedRefreshToken},
      );

      print('🔄 Ответ сервера: ${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          print('✅ Токены обновлены');
          await storage.write(
            key: AppConstants.accessTokenKey,
            value: newAccessToken,
          );
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await storage.write(
              key: AppConstants.refreshTokenKey,
              value: newRefreshToken,
            );
          }
          return true;
        }
      }
      print('❌ Не удалось обновить токены');
      return false;
    } catch (e) {
      print('❌ Ошибка обновления токена: $e');
      return false;
    }
  }

  /// Получить access token из secure storage
  Future<String?> _getAccessToken() async {
    try {
      final storage = SecureStorageService();
      return await storage.read(AppConstants.accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Очистить все токены
  Future<void> _clearAllTokens() async {
    try {
      final storage = SecureStorageService();
      await storage.delete(AppConstants.accessTokenKey);
      await storage.delete(AppConstants.refreshTokenKey);
      await storage.delete(AppConstants.demoSessionUserKey);
    } catch (e) {
      // Ignored
    }
  }

  /// POST запрос
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      // Преобразуем любую ошибку в DioException если нужно
      if (e is DioException) {
        throw _mapDioError(e);
      }
      throw const NetworkException();
    }
  }

  /// POST multipart/form-data
  Future<Response> postMultipart(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      if (e is DioException) {
        throw _mapDioError(e);
      }
      throw const NetworkException();
    }
  }

  /// PUT запрос
  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      if (e is DioException) {
        throw _mapDioError(e);
      }
      throw const NetworkException();
    }
  }

  /// PUT multipart/form-data
  Future<Response> putMultipart(String path, dynamic data) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      if (e is DioException) {
        throw _mapDioError(e);
      }
      throw const NetworkException();
    }
  }

  /// GET запрос
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      if (e is DioException) {
        throw _mapDioError(e);
      }
      throw const NetworkException();
    }
  }

  /// PATCH request
  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.patch(path, data: data);
    } catch (e) {
      if (e is DioException) {
        throw _mapDioError(e);
      }
      throw const NetworkException();
    }
  }

  /// DELETE запрос
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      if (e is DioException) {
        throw _mapDioError(e);
      }
      throw const NetworkException();
    }
  }

  /// POST запрос для logout
  Future<Response> postLogout(String path) async {
    try {
      return await _dio.post(path);
    } catch (e) {
      if (e is DioException) {
        throw _mapDioError(e);
      }
      throw const NetworkException();
    }
  }

  /// Маппинг DioException в AuthException
  AuthException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return const UnauthorizedException();
        }
        if (statusCode == 403) {
          return const AccountLockedException();
        }
        if (statusCode == 409) {
          final message = _extractServerMessage(error.response?.data);
          return ConflictException(
            message: message ?? 'Такой аккаунт уже существует. Попробуйте другой email или имя.',
          );
        }
        if (statusCode == 422) {
          // Пытаемся распарсить ошибки валидации
          try {
            final errors =
                error.response?.data['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              return ValidationException(
                message: 'Ошибка валидации',
                fieldErrors: errors.cast<String, String>(),
              );
            }
          } catch (_) {
            // Ignored
          }
        }
        if (statusCode != null && statusCode >= 500) {
          return const ServerException();
        }
        return ServerException(
          message: 'Сервер вернул ошибку $statusCode',
        );

      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          message:
              'Превышено время ожидания ответа от сервера',
        );

      case DioExceptionType.cancel:
        return const NetworkException(message: 'Запрос отменён');

      default:
        return NetworkException(
          message: error.message ?? 'Неизвестная ошибка',
        );
    }
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }

    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }

    return null;
  }

  /// Установка токена авторизации
  void setToken(String token) {
    // Реализация через SecureStorage
  }

  /// Получение токена
  String? getToken() {
    // Реализация через SecureStorage
    return null;
  }

  /// Удаление токена
  void clearToken() {
    // Реализация через SecureStorage
  }
}
