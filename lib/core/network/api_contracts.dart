class ApiEndpoints {
  const ApiEndpoints._();

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authPasswordReset = '/auth/password/reset';

  static const String usersMe = '/users/me';
  static const String usersProfile = '/users/profile';

  static const String tournaments = '/tournaments';
  static const String tournamentById = '/tournaments/{id}';
  static const String tournamentPlayers = '/tournaments/{id}/players';
}

class ApiJsonContracts {
  const ApiJsonContracts._();

  static Map<String, dynamic> loginRequest({
    required String login,
    required String password,
    required bool rememberMe,
  }) => {
    'login': login,
    'password': password,
    'remember_me': rememberMe,
  };

  static Map<String, dynamic> registerRequest({
    required String name,
    required String email,
    required String password,
  }) => {
    'name': name,
    'email': email,
    'password': password,
  };

  static Map<String, dynamic> refreshRequest({required String refreshToken}) => {
    'refresh_token': refreshToken,
  };

  static Map<String, dynamic> userProfileResponse({
    required String id,
    required String login,
    required String email,
    required String role,
    String? firstName,
    String? lastName,
  }) => {
    'id': id,
    'login': login,
    'email': email,
    'role': role,
    'first_name': firstName,
    'last_name': lastName,
    'is_active': true,
    'created_at': DateTime.now().toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
  };

  static Map<String, dynamic> tournamentResponse({
    required String id,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int maxPlayers,
    required double buyIn,
    required String format,
    required String status,
    List<String> registeredPlayers = const [],
  }) => {
    'id': id,
    'name': name,
    'description': description,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'max_players': maxPlayers,
    'buy_in': buyIn,
    'format': format,
    'status': status,
    'registered_players': registeredPlayers,
  };
}
