import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tournament_model.dart';

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
  TournamentNotifier()
    : super([
        Tournament(
          id: '1',
          name: 'Sunday Mega Tournament',
          description: 'Главный воскресный турнир с призовым фондом 500,000₽',
          startDate: DateTime.now().add(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 3)),
          maxPlayers: 100,
          buyIn: 1000,
          format: 'TT No-Limit',
          status: 'upcoming',
          registeredPlayerIds: ['player1', 'player2', 'player3'],
        ),
        Tournament(
          id: '2',
          name: 'Monday Mystery Battle',
          description: 'Турнир с неизвестной структуройblind-ов',
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 2)),
          maxPlayers: 50,
          buyIn: 500,
          format: 'TT No-Limit',
          status: 'inProgress',
          registeredPlayerIds: ['player4', 'player5'],
        ),
        Tournament(
          id: '3',
          name: 'Friday Night Championship',
          description: 'Чемпионский турнир с рейтинговыми очками',
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          endDate: DateTime.now().subtract(const Duration(days: 6)),
          maxPlayers: 200,
          buyIn: 2000,
          format: 'TT No-Limit',
          status: 'completed',
          registeredPlayerIds: ['player6', 'player7', 'player8', 'player9'],
        ),
        Tournament(
          id: '4',
          name: 'Quick Spin 30',
          description: 'Быстрый турнир на 30 минут',
          startDate: DateTime.now().add(const Duration(hours: 5)),
          endDate: DateTime.now().add(const Duration(hours: 6)),
          maxPlayers: 30,
          buyIn: 200,
          format: 'TT No-Limit',
          status: 'upcoming',
          registeredPlayerIds: [],
        ),
      ]);

  void addTournament(Tournament tournament) {
    state = [tournament, ...state];
  }

  void updateTournament(Tournament updated) {
    state = [...state.map((t) => t.id == updated.id ? updated : t)];
  }

  void deleteTournament(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  TournamentRegistrationResult registerPlayer(
    String tournamentId,
    String playerId,
  ) {
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

    state = [
      for (final item in state)
        if (item.id == tournamentId)
          _copyTournament(
            item,
            registeredPlayerIds: [...item.registeredPlayerIds, playerId],
          )
        else
          item,
    ];
    return TournamentRegistrationResult.success;
  }

  bool removePlayer(String tournamentId, String playerId) {
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
