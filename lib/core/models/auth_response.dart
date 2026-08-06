import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Ответ от сервера при авторизации
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    required User user,
    @Default(true) bool requiresMfa,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
