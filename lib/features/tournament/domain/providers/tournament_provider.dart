import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../data/datasources/tournament_remote_data_source.dart';
import '../../data/repositories/tournament_repository_impl.dart';
import '../../domain/repositories/tournament_repository_contract.dart';
import '../../domain/usecases/get_tournaments_usecase.dart';
import '../../domain/usecases/register_player_usecase.dart';
import '../models/tournament_model.dart';

final tournamentRemoteDataSourceProvider = Provider<TournamentRemoteDataSource>(
  (ref) => TournamentRemoteDataSourceImpl(
    apiService: ref.watch(apiServiceProvider),
  ),
);

final tournamentRepositoryProvider = Provider<TournamentRepositoryContract>(
  (ref) => TournamentRepositoryImpl(
    remoteDataSource: ref.watch(tournamentRemoteDataSourceProvider),
  ),
);

final getTournamentsUseCaseProvider = Provider<GetTournamentsUseCase>(
  (ref) => GetTournamentsUseCase(ref.read(tournamentRepositoryProvider)),
);

final registerPlayerUseCaseProvider = Provider<RegisterPlayerUseCase>(
  (ref) => RegisterPlayerUseCase(ref.read(tournamentRepositoryProvider)),
);

enum TournamentRegistrationResult {
  success,
  duplicate,
  full,
  registrationClosed,
  notFound;

  String get message => switch (this) {
    success => 'Вы зарегистрированы на турнир',
    duplicate => 'Вы уже зарегистрированы',
    full => 'В турнире нет свободных мест',
    registrationClosed => 'Регистрация на турнир закрыта',
    notFound => 'Турнир не найден',
  };
}

class TournamentStats {
  final int total;
  final int upcoming;
  final int inProgress;
  final int completed;

  const TournamentStats({
    required this.total,
    required this.upcoming,
    required this.inProgress,
    required this.completed,
  });
}

class TournamentNotifier extends StateNotifier<List<Tournament>> {
  TournamentNotifier() : super(const []) {
    load();
  }

  Future<void> load() async {
    try {
      final response = await ApiService().get('/tournaments');
      final data = response.data as List<dynamic>;
      state = data
          .map((item) => Tournament.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> addTournament(Tournament tournament) async {
    try {
      final response = await ApiService().post('/tournaments', data: {
        'name': tournament.name,
        'description': tournament.description,
        'start_date': tournament.startDate.toIso8601String(),
        'end_date': tournament.endDate.toIso8601String(),
        'max_players': tournament.maxPlayers,
        'buy_in': tournament.buyIn,
        'format': tournament.format,
        'status': tournament.status,
      });
      if (response.data != null) {
        final created = Tournament.fromJson(response.data as Map<String, dynamic>);
        state = [created, ...state];
      }
    } catch (e) {
      print('Ошибка создания турнира: $e');
      // Не добавляем в стейт при ошибке
    }
  }

  Future<void> updateTournament(Tournament tournament) async {
    try {
      await ApiService().post('/tournaments/${tournament.id}', data: {
        'name': tournament.name,
        'description': tournament.description,
        'start_date': tournament.startDate.toIso8601String(),
        'end_date': tournament.endDate.toIso8601String(),
        'max_players': tournament.maxPlayers,
        'buy_in': tournament.buyIn,
        'format': tournament.format,
        'status': tournament.status,
      });
      // Обновляем локально
      state = [...state.map((t) => t.id == tournament.id ? tournament : t)];
    } catch (e) {
      print('Ошибка обновления турнира: $e');
    }
  }

  Future<void> deleteTournament(String id) async {
    try {
      await ApiService().post('/tournaments/$id/delete');
      state = state.where((t) => t.id != id).toList();
    } catch (e) {
      print('Ошибка удаления турнира: $e');
    }
  }

  Future<TournamentRegistrationResult> registerPlayer(
    String tournamentId,
    String playerId,
  ) async {
    try {
      final response = await ApiService().post('/tournaments/$tournamentId/players', data: {
        'player_id': playerId,
      });
      
      if (response.data != null) {
        final updated = Tournament.fromJson(response.data as Map<String, dynamic>);
        state = [
          for (final item in state)
            if (item.id == tournamentId) updated else item,
        ];
      }
      
      final index = state.indexWhere((t) => t.id == tournamentId);
      if (index < 0) return TournamentRegistrationResult.notFound;

      final tournament = state[index];
      if (tournament.registeredPlayerIds.contains(playerId)) {
        return TournamentRegistrationResult.duplicate;
      }
      if (tournament.status != 'upcoming') {
        return TournamentRegistrationResult.registrationClosed;
      }
      if (tournament.isFull) return TournamentRegistrationResult.full;

      return TournamentRegistrationResult.success;
    } catch (e) {
      print('Ошибка регистрации игрока: $e');
      return TournamentRegistrationResult.notFound;
    }
  }

  Future<bool> removePlayer(String tournamentId, String playerId) async {
    try {
      await ApiService().delete('/tournaments/$tournamentId/players/$playerId');
      
      final index = state.indexWhere((t) => t.id == tournamentId);
      if (index < 0 || !state[index].registeredPlayerIds.contains(playerId)) {
        return false;
      }
      state = [
        for (final item in state)
          if (item.id == tournamentId)
            _copyTournament(
              item,
              registeredPlayerIds: item.registeredPlayerIds
                  .where((id) => id != playerId)
                  .toList(),
            )
          else
            item,
      ];
      return true;
    } catch (e) {
      print('Ошибка удаления игрока: $e');
      return false;
    }
  }

  Tournament _copyTournament(
    Tournament tournament, {
    List<String>? registeredPlayerIds,
  }) {
    return Tournament(
      id: tournament.id,
      name: tournament.name,
      description: tournament.description,
      startDate: tournament.startDate,
      endDate: tournament.endDate,
      maxPlayers: tournament.maxPlayers,
      buyIn: tournament.buyIn,
      format: tournament.format,
      status: tournament.status,
      registeredPlayerIds:
          registeredPlayerIds ?? tournament.registeredPlayerIds,
    );
  }

  void updateStatus(String tournamentId, String newStatus) {
    state = [
      ...state.map((t) {
        if (t.id == tournamentId) {
          return Tournament(
            id: t.id,
            name: t.name,
            description: t.description,
            startDate: t.startDate,
            endDate: t.endDate,
            maxPlayers: t.maxPlayers,
            buyIn: t.buyIn,
            format: t.format,
            status: newStatus,
            registeredPlayerIds: t.registeredPlayerIds,
          );
        }
        return t;
      }),
    ];
  }

  TournamentStats getStats() {
    return TournamentStats(
      total: state.length,
      upcoming: state.where((t) => t.status == 'upcoming').length,
      inProgress: state.where((t) => t.status == 'inProgress').length,
      completed: state.where((t) => t.status == 'completed').length,
    );
  }
}

final tournamentProvider =
    StateNotifierProvider<TournamentNotifier, List<Tournament>>(
      (ref) => TournamentNotifier(),
    );
