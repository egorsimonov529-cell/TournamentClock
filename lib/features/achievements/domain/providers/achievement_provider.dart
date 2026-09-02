import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../player/domain/providers/player_provider.dart';
import '../../../tournament/domain/models/tournament_model.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../models/achievement.dart';

final achievementProvider = StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  final notifier = AchievementNotifier(ref);

  ref.listen<List<Tournament>>(tournamentProvider, (_, __) => notifier.refresh());
  ref.listen(playerProfileProvider, (_, __) => notifier.refresh());

  return notifier;
});

class AchievementNotifier extends StateNotifier<List<Achievement>> {
  AchievementNotifier(this._ref) : super(const []) {
    refresh();
  }

  final Ref _ref;

  void refresh() {
    final tournaments = _ref.read(tournamentProvider);
    final player = _ref.read(playerProfileProvider).valueOrNull;
    final userId = player?.userId ?? '';

    final playedTournaments = tournaments
        .where((t) => t.registeredPlayerIds.contains(userId))
        .toList();
    final completedTournaments = playedTournaments
        .where((t) => t.status == 'completed')
        .toList();
    final nightTournaments = playedTournaments
        .where((t) => t.startDate.hour >= 23)
        .toList();
    final totalSpend = playedTournaments.fold<double>(0, (sum, tournament) => sum + tournament.buyIn);

    final derived = [
      Achievement(
        id: 'first-tournament',
        title: 'Первый турнир',
        description: 'Примите участие в первом турнире',
        imageUrl: 'assets/images/achievement_first_tournament.svg',
        currentValue: playedTournaments.isNotEmpty ? 1 : 0,
        targetValue: 1,
        achieved: playedTournaments.isNotEmpty,
      ),
      Achievement(
        id: 'regular',
        title: 'Регуляр',
        description: 'Участвуйте в 10 турнирах',
        imageUrl: 'assets/images/achievement_regular.svg',
        currentValue: playedTournaments.length,
        targetValue: 10,
        achieved: playedTournaments.length >= 10,
      ),
      Achievement(
        id: 'winner',
        title: 'Победитель',
        description: 'Завершите турнир в числе победителей',
        imageUrl: 'assets/images/achievement_winner.svg',
        currentValue: completedTournaments.length,
        targetValue: 1,
        achieved: completedTournaments.isNotEmpty,
      ),
      Achievement(
        id: 'big-win',
        title: 'Крупный выигрыш',
        description: 'Накопите 50 000 ₽ по участию в турнирах',
        imageUrl: 'assets/images/achievement_big_win.svg',
        currentValue: totalSpend.round(),
        targetValue: 50000,
        achieved: totalSpend >= 50000,
      ),
      Achievement(
        id: 'night-player',
        title: 'Ночной игрок',
        description: 'Участвуйте в турнирах после 23:00',
        imageUrl: 'assets/images/achievement_night_player.svg',
        currentValue: nightTournaments.length,
        targetValue: 5,
        achieved: nightTournaments.length >= 5,
      ),
      Achievement(
        id: 'high-roller',
        title: 'High Roller',
        description: 'Покажите 100 000 ₽ суммарного участия',
        imageUrl: 'assets/images/achievement_high_roller.svg',
        currentValue: totalSpend.round(),
        targetValue: 100000,
        achieved: totalSpend >= 100000,
      ),
    ];

    state = derived;
  }

  void addAchievement(Achievement achievement) {
    state = [achievement, ...state];
  }

  void updateAchievement(Achievement achievement) {
    state = [
      for (final item in state)
        if (item.id == achievement.id) achievement else item,
    ];
  }

  void removeAchievement(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}
