import '../../../../core/models/auth_exception.dart';
import '../../../../core/models/auth_response.dart';
import '../repositories/auth_repository_contract.dart';

class RegisterUseCase {
  final AuthRepositoryContract _repository;

  const RegisterUseCase(this._repository);

  Future<AuthResponse> call({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    if (name.trim().isEmpty) {
      throw const ValidationException(
        message: 'Имя обязательно',
        fieldErrors: {'name': 'Имя обязательно'},
      );
    }

    if (email.trim().isEmpty) {
      throw const ValidationException(
        message: 'Email обязателен',
        fieldErrors: {'email': 'Email обязателен'},
      );
    }

    if (password.length < 6) {
      throw const ValidationException(
        message: 'Пароль должен содержать минимум 6 символов',
        fieldErrors: {'password': 'Пароль должен содержать минимум 6 символов'},
      );
    }

    if (!acceptedTerms) {
      throw const ValidationException(
        message: 'Необходимо согласие с правилами',
        fieldErrors: {'acceptedTerms': 'Необходимо согласие'},
      );
    }

    return _repository.register(
      name: name.trim(),
      email: email.trim(),
      password: password,
      acceptedTerms: acceptedTerms,
    );
  }
}
