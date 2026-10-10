import '../../../../core/models/auth_response.dart';
import '../../../../core/models/user.dart';
import '../models/demo_session.dart';

abstract class AuthRepositoryContract {
  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  });

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  });

  Future<AuthResponse> refreshToken({required String refreshToken});

  Future<void> requestPasswordReset({required String contact});

  Future<void> logout();

  Future<DemoSession> restoreSession();

  Future<User?> checkSession();

  Future<AuthResponse?> autoLogin();

  Future<User?> getCurrentUser();

  Future<void> clearAll();
}
