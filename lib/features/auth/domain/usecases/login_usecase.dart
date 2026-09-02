import '../../../../core/models/auth_exception.dart';
import '../../../../core/models/auth_response.dart';
import '../repositories/auth_repository_contract.dart';

class LoginUseCase {
  final AuthRepositoryContract _repository;

  const LoginUseCase(this._repository);

  Future<AuthResponse> call({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async {
    if (login.trim().isEmpty) {
      throw const ValidationException(
        message: 'Логин обязателен',
        fieldErrors: {'login': 'Логин обязателен'},
      );
    }

    if (password.trim().isEmpty) {
      throw const ValidationException(
        message: 'Пароль обязателен',
        fieldErrors: {'password': 'Пароль обязателен'},
      );
    }

    return _repository.login(
      login: login.trim(),
      password: password,
      rememberMe: rememberMe,
    );
  }
}
