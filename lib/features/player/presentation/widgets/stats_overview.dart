import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_model.dart';

class StatsOverview extends StatelessWidget {
  final PlayerProfile player;

  const StatsOverview({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 700;
    final compactPhone = width < 420;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compactPhone ? 12 : isPhone ? 14 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  'История игр',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${player.totalTournaments} игр',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth < 420
                  ? (constraints.maxWidth - 12) / 2
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard(
                    icon: CupertinoIcons.flag,
                    title: 'Игры',
                    value: '${player.totalTournaments}',
                    color: AppColors.primary,
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    icon: CupertinoIcons.check_mark_circled_solid,
                    title: 'Победы',
                    value: '${player.totalWins}',
                    color: AppColors.gold,
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    icon: CupertinoIcons.chart_bar,
                    title: 'Топ-3',
                    value: '${player.totalPodiums}',
                    color: AppColors.primaryLight,
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    icon: CupertinoIcons.arrow_up_right,
                    title: 'RPS',
                    value: '${player.rpsPoints}',
                    color: AppColors.info,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _buildRankProgress(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRankProgress(BuildContext context) {
    final rpsRank = player.rpsRank;
    final rpsPoints = player.rpsPoints;

    final nextIndex = rpsRank.index + 1;
    final next = nextIndex < RpsRank.values.length
        ? RpsRank.values[nextIndex]
        : null;
    final start = rpsRank.baseScore;
    final target = next?.baseScore ?? start;
    final progress = next == null
        ? 1.0
        : ((rpsPoints - start) / (target - start)).clamp(0.0, 1.0);
    final remaining = next == null ? 0 : (target - rpsPoints).clamp(0, 999999);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  next == null
                      ? 'Максимальный ранг достигнут'
                      : 'До ранга ${next.label}: $remaining RPS',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final screenWidth = MediaQuery.sizeOf(context);
                  final isWide = screenWidth.width > 600;
                  
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      final dialogWidth = isWide ? 400.0 : screenWidth.width * 0.9;
                      final dialogHeight = screenWidth.height * 0.75;
                      
                      return AlertDialog(
                        backgroundColor: const Color(0xFF1D232C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Система рангов RPS',
                          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                        content: SizedBox(
                          width: dialogWidth,
                          height: dialogHeight,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Накопляй RPS за участие в турнирах и поднимайся по лестнице рангов!',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(height: 16),
                                ...RpsRank.values.map((rank) {
                                  final isCurrent = rpsRank == rank;
                                  final isUnlocked = rpsPoints >= rank.baseScore;
                                  final nextRank = rank.index + 1 < RpsRank.values.length
                                      ? RpsRank.values[rank.index + 1]
                                      : null;
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? AppColors.primary.withValues(alpha: 0.2)
                                          : isUnlocked
                                              ? AppColors.gold.withValues(alpha: 0.1)
                                              : AppColors.card,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCurrent
                                            ? AppColors.primary
                                            : isUnlocked
                                                ? AppColors.gold.withValues(alpha: 0.4)
                                                : AppColors.border.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCurrent
                                              ? Icons.emoji_events
                                              : isUnlocked
                                                  ? Icons.check_circle
                                                  : Icons.lock,
                                          color: isCurrent
                                              ? AppColors.primary
                                              : isUnlocked
                                                  ? AppColors.gold
                                                  : AppColors.textSecondary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    rank.label,
                                                    style: TextStyle(
                                                      color: AppColors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (isCurrent) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary,
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: const Text(
                                                        'ТЫ',
                                                        style: TextStyle(
                                                          color: AppColors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${rank.baseScore} RPS',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (nextRank != null)
                                          Text(
                                            '${nextRank.baseScore - rank.baseScore} RPS',
                                            style: TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Закрыть', style: TextStyle(color: AppColors.accent)),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Все ранги',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Победы: ${player.totalWins} • Подиумы: ${player.totalPodiums} • Win rate: ${player.winRate.toStringAsFixed(1)}%',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.24), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
