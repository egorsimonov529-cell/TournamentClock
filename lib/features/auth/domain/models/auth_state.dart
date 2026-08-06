enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  error,
  loggingOut,
}

class AuthState {
  final AuthStatus status;
  final String? accessToken;
  final String? refreshToken;
  final String? message;

  const AuthState({
    this.status = AuthStatus.initial,
    this.accessToken,
    this.refreshToken,
    this.message,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? refreshToken,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      message: message ?? this.message,
    );
  }
}