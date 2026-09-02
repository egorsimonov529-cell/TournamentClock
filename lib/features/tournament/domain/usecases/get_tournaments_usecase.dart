import '../models/tournament_model.dart';
import '../repositories/tournament_repository_contract.dart';

class GetTournamentsUseCase {
  final TournamentRepositoryContract _repository;

  const GetTournamentsUseCase(this._repository);

  Future<List<Tournament>> call() => _repository.getTournaments();
}
