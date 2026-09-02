import '../repositories/tournament_repository_contract.dart';

class RegisterPlayerUseCase {
  final TournamentRepositoryContract _repository;

  const RegisterPlayerUseCase(this._repository);

  Future<void> call({required String tournamentId, required String playerId}) =>
      _repository.registerPlayer(tournamentId: tournamentId, playerId: playerId);
}
