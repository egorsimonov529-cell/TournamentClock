import '../models/tournament_model.dart';

abstract class TournamentRepositoryContract {
  Future<List<Tournament>> getTournaments();
  Future<Tournament> getTournamentById(String id);
  Future<Tournament> createTournament({required Tournament tournament});
  Future<Tournament> updateTournament({required Tournament tournament});
  Future<void> deleteTournament(String id);
  Future<void> registerPlayer({required String tournamentId, required String playerId});
  Future<void> unregisterPlayer({required String tournamentId, required String playerId});
}
