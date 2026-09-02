import '../../../../core/models/auth_response.dart';
import 'auth_repository_contract.dart';

abstract class AuthRepository extends AuthRepositoryContract {
  Future<AuthResponse> signInWithGoogle();
}
