import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onOpenTournaments;
  final VoidCallback onOpenLeaderboard;

  const QuickActions({
    super.key,
    required this.onOpenTournaments,
    required this.onOpenLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 650;
    final narrow = width < 420;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final cards = [
      _buildActionCard(
        icon: Icons.emoji_events_rounded,
        title: 'Найти турнир',
        description: 'Посмотрите доступные турниры и зарегистрируйтесь',
        onTap: onOpenTournaments,
        isIOS: isIOS,
      ),
      _buildActionCard(
        icon: Icons.insights_rounded,
        title: 'Мой рейтинг',
        description: 'Следите за прогрессом в RPS',
        onTap: onOpenLeaderboard,
        isIOS: isIOS,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : compact ? 14 : 32),
      child: compact
          ? Column(
              children: [cards.first, const SizedBox(height: 12), cards.last],
            )
          : Row(
              children: [
                Expanded(child: cards.first),
                const SizedBox(width: 16),
                Expanded(child: cards.last),
              ],
            ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isIOS,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.primary.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.32),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 12.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primary,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
