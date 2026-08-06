import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/auth_exception.dart';

/// HTTP-сервис для работы с API
class ApiService {
  late final Dio _dio;

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
        );

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

  /// GET запрос
  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
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
        if (statusCode == 422) {
          // Пытаемся распарсить ошибки валидации
          try {
            final errors = error.response?.data['errors'] as Map<String, dynamic>?;
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
          message: 'Превышено время ожидания ответа от сервера',
        );

      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Запрос отменён',
        );

      default:
        return NetworkException(
          message: error.message ?? 'Неизвестная ошибка',
        );
    }
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
