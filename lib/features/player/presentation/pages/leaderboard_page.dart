import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Таблица лидеров",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Общий рейтинг спортсменов",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildTop3Podium(),
          const SizedBox(height: 32),
          const Text(
            "Полный рейтинг",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildRankingTable(),
        ],
      ),
    );
  }

  Widget _buildTop3Podium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 2nd place
        _buildPodiumPlayer(
          rank: 2,
          name: "Dmitry K.",
          points: 2850,
          wins: 12,
          color: const Color(0xff94A3B8),
          height: 180,
          isSecond: true,
        ),
        const SizedBox(width: 24),
        // 1st place
        _buildPodiumPlayer(
          rank: 1,
          name: "Alexei V.",
          points: 3120,
          wins: 15,
          color: AppColors.primary,
          height: 220,
          isFirst: true,
        ),
        const SizedBox(width: 24),
        // 3rd place
        _buildPodiumPlayer(
          rank: 3,
          name: "Maxim R.",
          points: 2740,
          wins: 11,
          color: const Color(0xffB45309),
          height: 160,
          isThird: true,
        ),
      ],
    );
  }

  Widget _buildPodiumPlayer({
    required int rank,
    required String name,
    required int points,
    required int wins,
    required Color color,
    required double height,
    bool isFirst = false,
    bool isSecond = false,
    bool isThird = false,
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
              border: Border.all(
                color: color,
                width: 3,
              ),
            ),
            child: Center(
              child: Icon(
                rank == 1
                    ? Icons.emoji_events_rounded
                    : rank == 2
                        ? Icons.emoji_events_rounded
                        : Icons.emoji_events_rounded,
                color: color,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$points очков",
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$wins побед",
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
              border: Border(
                top: BorderSide(
                  color: color,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTable() {
    final List<Map<String, dynamic>> rankings = [
      {"rank": 1, "name": "Alexei V.", "points": 3120, "wins": 15, "games": 42},
      {"rank": 2, "name": "Dmitry K.", "points": 2850, "wins": 12, "games": 38},
      {"rank": 3, "name": "Maxim R.", "points": 2740, "wins": 11, "games": 35},
      {"rank": 4, "name": "Petr A.", "points": 2680, "wins": 10, "games": 40},
      {"rank": 5, "name": "Ivan S.", "points": 2550, "wins": 9, "games": 36},
      {"rank": 6, "name": "Sergei M.", "points": 2480, "wins": 9, "games": 34},
      {"rank": 7, "name": "Andrei L.", "points": 2390, "wins": 8, "games": 33},
      {"rank": 8, "name": "Nikolay B.", "points": 2310, "wins": 7, "games": 30},
      {"rank": 9, "name": "Vladimir T.", "points": 2250, "wins": 7, "games": 32},
      {"rank": 10, "name": "PokerStar123", "points": 2180, "wins": 6, "games": 28, "isCurrentUser": true},
    ];

    return Column(
      children: rankings.map((player) {
        final isCurrentUser = player['isCurrentUser'] as bool? ?? false;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppColors.primary.withValues(alpha: 0.1)
                : const Color(0xff1D232C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentUser
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : const Color(0xff2A2D35),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: player['rank'] <= 3
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : const Color(0xff2A2D35),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "#${player['rank']}",
                    style: TextStyle(
                      color: player['rank'] <= 3
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
                        Text(
                          player['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
                              "Вы",
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
                      "${player['wins']} побед / ${player['games']} игр",
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
                  "${player['points']}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
