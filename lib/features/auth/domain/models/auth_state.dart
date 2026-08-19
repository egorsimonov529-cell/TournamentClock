enum AuthStatus { initial, authenticating, authenticated, error, loggingOut }

class AuthState {
  final AuthStatus status;
  final String? accessToken;
  final String? refreshToken;
  final String? message;
  final String? userRole; // "admin" или "player"

  const AuthState({
    this.status = AuthStatus.initial,
    this.accessToken,
    this.refreshToken,
    this.message,
    this.userRole,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? refreshToken,
    String? message,
    String? userRole,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      message: message ?? this.message,
      userRole: userRole ?? this.userRole,
    );
  }
}
