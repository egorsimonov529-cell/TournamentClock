class BackendApiContracts {
  const BackendApiContracts._();

  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';

  static const String currentUser = '/api/v1/users/me';
  static const String profile = '/api/v1/users/profile';

  static const String tournaments = '/api/v1/tournaments';
  static const String tournamentById = '/api/v1/tournaments/{id}';
  static const String tournamentPlayers = '/api/v1/tournaments/{id}/players';

  static const String tables = '/api/v1/tables';
  static const String tableById = '/api/v1/tables/{id}';
  static const String players = '/api/v1/players';
  static const String playerById = '/api/v1/players/{id}';

  static const String adminWorkspace = '/api/v1/admin/workspace';
  static const String adminRanks = '/api/v1/admin/ranks';
  static const String adminPlayers = '/api/v1/admin/players';
  static const String adminSettings = '/api/v1/admin/settings';
}
