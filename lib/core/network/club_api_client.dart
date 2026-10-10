import '../../features/tournament/domain/models/tournament_model.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'api_contracts.dart';

class ClubApiClient {
  final ApiService _apiService;

  const ClubApiClient(this._apiService);

  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.authLogin,
      data: ApiJsonContracts.loginRequest(
        login: login,
        password: password,
        rememberMe: rememberMe,
      ),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.authRegister,
      data: ApiJsonContracts.registerRequest(
        name: name,
        email: email,
        password: password,
      ),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    final response = await _apiService.post(
      ApiEndpoints.authRefresh,
      data: ApiJsonContracts.refreshRequest(refreshToken: refreshToken),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiService.postLogout(ApiEndpoints.authLogout);
  }

  Future<void> requestPasswordReset({required String contact}) async {
    await _apiService.post(
      ApiEndpoints.authPasswordReset,
      data: {'contact': contact},
    );
  }

  Future<User> getCurrentUser() async {
    final response = await _apiService.get(ApiEndpoints.usersMe);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> getProfile() async {
    final response = await _apiService.get(ApiEndpoints.usersProfile);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateProfile({required User user}) async {
    final response = await _apiService.post(
      ApiEndpoints.usersProfile,
      data: user.toJson(),
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Tournament>> getTournaments() async {
    final response = await _apiService.get(ApiEndpoints.tournaments);
    final list = response.data as List<dynamic>;
    return list
        .map((item) => Tournament.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Tournament> createTournament({required Tournament tournament}) async {
    final response = await _apiService.post(
      ApiEndpoints.tournaments,
      data: tournament.toJson(),
    );
    return Tournament.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Tournament> updateTournament({required Tournament tournament}) async {
    final response = await _apiService.post(
      ApiEndpoints.tournamentById.replaceFirst('{id}', tournament.id),
      data: tournament.toJson(),
    );
    return Tournament.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTournament(String id) async {
    await _apiService.post(
      ApiEndpoints.tournamentById.replaceFirst('{id}', id),
      data: {'_method': 'DELETE'},
    );
  }

  Future<void> registerPlayer({
    required String tournamentId,
    required String playerId,
  }) async {
    await _apiService.post(
      ApiEndpoints.tournamentPlayers.replaceFirst('{id}', tournamentId),
      data: {'player_id': playerId},
    );
  }
}
