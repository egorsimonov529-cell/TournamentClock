import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../../features/auth/domain/providers/auth_state_provider.dart';
import '../../../../features/players/domain/models/admin_player.dart';
import '../../../../features/players/domain/providers/admin_players_provider.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = [...ref.watch(adminPlayersProvider).players]
      ..sort((a, b) => b.rpsPoints.compareTo(a.rpsPoints));
    final authUser = ref.watch(currentAuthUserProvider).valueOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Таблица лидеров',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Общий рейтинг спортсменов',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildTop3Podium(players),
          const SizedBox(height: 32),
          const Text(
            'Полный рейтинг',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildRankingTable(players, authUser?.login),
        ],
      ),
    );
  }

  Widget _buildTop3Podium(List<AdminPlayer> players) {
    if (players.isEmpty) {
      return const Center(
        child: Text('Нет данных', style: TextStyle(color: Colors.white54)),
      );
    }

    final podium = <Widget>[];
    void addPlayer(int index, Color color, double height) {
      if (index >= players.length) return;
      podium.add(
        _buildPodiumPlayer(
          rank: index + 1,
          player: players[index],
          color: color,
          height: height,
        ),
      );
    }

    addPlayer(1, const Color(0xff94A3B8), 180);
    addPlayer(0, AppColors.primary, 220);
    addPlayer(2, const Color(0xffB45309), 160);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < podium.length; index++) ...[
          if (index > 0) const SizedBox(width: 24),
          podium[index],
        ],
      ],
    );
  }

  Widget _buildPodiumPlayer({
    required int rank,
    required AdminPlayer player,
    required Color color,
    required double height,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Icon(Icons.emoji_events_rounded, color: color, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            player.name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${player.rpsPoints > 0 ? player.rpsPoints.toString() : '—'} очков',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${player.wins} побед',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: color, width: 2)),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTable(List<AdminPlayer> players, String? currentLogin) {
    return Column(
      children: players.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final player = entry.value;
        final isCurrentUser =
            currentLogin != null &&
            player.login.toLowerCase() == currentLogin.toLowerCase();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: IosCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : const Color(0xff2A2D35),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: rank <= 3
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                player.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Вы',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${player.wins} побед / ${player.tournaments} игр',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${player.rpsPoints}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
