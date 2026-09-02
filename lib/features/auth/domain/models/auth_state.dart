import '../../../../core/models/user.dart';

enum AuthStatus {
  initializing,
  anonymous,
  authenticating,
  authenticated,
  error,
  loggingOut,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? message;

  const AuthState({
    this.status = AuthStatus.initializing,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.message,
  });

  String? get userRole => user?.role;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}
