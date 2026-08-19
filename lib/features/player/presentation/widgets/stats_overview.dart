import 'package:flutter/material.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_model.dart';

class StatsOverview extends StatelessWidget {
  final PlayerProfile player;

  const StatsOverview({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Ваша статистика",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < 700
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 48) / 4;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard(
                    icon: Icons.emoji_events_rounded,
                    title: 'Турниров',
                    value: '${player.totalTournaments}',
                    color: AppColors.primary,
                    width: width,
                  ),
                  _buildStatCard(
                    icon: Icons.verified_rounded,
                    title: 'Побед',
                    value: '${player.totalWins}',
                    color: AppColors.warning,
                    width: width,
                  ),
                  _buildStatCard(
                    icon: Icons.workspace_premium_rounded,
                    title: 'RPS',
                    value: player.rpsRank.label,
                    color: AppColors.info,
                    width: width,
                  ),
                  _buildStatCard(
                    icon: Icons.insights_rounded,
                    title: 'Rating',
                    value: '${player.rankPoints}',
                    color: AppColors.success,
                    width: width,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _buildRankProgress(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRankProgress() {
    final nextIndex = player.rpsRank.index + 1;
    final next = nextIndex < RpsRank.values.length
        ? RpsRank.values[nextIndex]
        : null;
    final start = player.rpsRank.baseScore;
    final target = next?.baseScore ?? start;
    final progress = next == null
        ? 1.0
        : ((player.rankPoints - start) / (target - start)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            next == null
                ? 'Максимальный ранг достигнут'
                : 'До ранга ${next.label}: ${target - player.rankPoints} очков',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.white12,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            'Победы: ${player.totalWins} • Подиумы: ${player.totalPodiums} • Win rate: ${player.winRate.toStringAsFixed(1)}%',
            style: TextStyle(color: Colors.white.withOpacity(.65)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff1D232C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
