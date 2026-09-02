import '../../../../core/network/api_contracts.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/models/tournament_model.dart';

abstract class TournamentRemoteDataSource {
  Future<List<Tournament>> getTournaments();
  Future<Tournament> getTournamentById(String id);
  Future<Tournament> createTournament({required Tournament tournament});
  Future<Tournament> updateTournament({required Tournament tournament});
  Future<void> deleteTournament(String id);
  Future<void> registerPlayer({required String tournamentId, required String playerId});
  Future<void> unregisterPlayer({required String tournamentId, required String playerId});
}

class TournamentRemoteDataSourceImpl implements TournamentRemoteDataSource {
  final ApiService _apiService;

  const TournamentRemoteDataSourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<Tournament>> getTournaments() async {
    final response = await _apiService.get(ApiEndpoints.tournaments);
    final data = response.data as List<dynamic>;
    return data
        .map((json) => Tournament.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Tournament> getTournamentById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.tournamentById.replaceFirst('{id}', id),
    );
    return Tournament.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Tournament> createTournament({required Tournament tournament}) async {
    final response = await _apiService.post(
      ApiEndpoints.tournaments,
      data: tournament.toJson(),
    );
    return Tournament.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Tournament> updateTournament({required Tournament tournament}) async {
    final response = await _apiService.post(
      ApiEndpoints.tournamentById.replaceFirst('{id}', tournament.id),
      data: tournament.toJson(),
    );
    return Tournament.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTournament(String id) async {
    await _apiService.post('${ApiEndpoints.tournamentById.replaceFirst('{id}', id)}/delete');
  }

  @override
  Future<void> registerPlayer({required String tournamentId, required String playerId}) async {
    await _apiService.post(
      ApiEndpoints.tournamentPlayers.replaceFirst('{id}', tournamentId),
      data: {'player_id': playerId},
    );
  }

  @override
  Future<void> unregisterPlayer({required String tournamentId, required String playerId}) async {
    await _apiService.post(
      '${ApiEndpoints.tournamentPlayers.replaceFirst('{id}', tournamentId)}/remove',
      data: {'player_id': playerId},
    );
  }
}
