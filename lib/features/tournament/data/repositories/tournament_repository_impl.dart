import '../../domain/models/tournament_model.dart';
import '../../domain/repositories/tournament_repository_contract.dart';
import '../datasources/tournament_remote_data_source.dart';

class TournamentRepositoryImpl implements TournamentRepositoryContract {
  final TournamentRemoteDataSource _remoteDataSource;

  const TournamentRepositoryImpl({required TournamentRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Tournament>> getTournaments() => _remoteDataSource.getTournaments();

  @override
  Future<Tournament> getTournamentById(String id) => _remoteDataSource.getTournamentById(id);

  @override
  Future<Tournament> createTournament({required Tournament tournament}) =>
      _remoteDataSource.createTournament(tournament: tournament);

  @override
  Future<Tournament> updateTournament({required Tournament tournament}) =>
      _remoteDataSource.updateTournament(tournament: tournament);

  @override
  Future<void> deleteTournament(String id) => _remoteDataSource.deleteTournament(id);

  @override
  Future<void> registerPlayer({required String tournamentId, required String playerId}) =>
      _remoteDataSource.registerPlayer(tournamentId: tournamentId, playerId: playerId);

  @override
  Future<void> unregisterPlayer({required String tournamentId, required String playerId}) =>
      _remoteDataSource.unregisterPlayer(tournamentId: tournamentId, playerId: playerId);
}
