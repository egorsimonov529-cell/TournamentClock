import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Карточка уровня лояльности
class LoyaltyLevelCard extends StatelessWidget {
  final String level;
  final int currentPoints;
  final int requiredPoints;
  final String nextLevel;
  final int nextLevelRequired;
  final Color? levelColor;
  final List<String> benefits;

  const LoyaltyLevelCard({
    super.key,
    required this.level,
    required this.currentPoints,
    required this.requiredPoints,
    required this.nextLevel,
    required this.nextLevelRequired,
    this.levelColor,
    this.benefits = const [],
  });

  @override
  Widget build(BuildContext context) {
    final color = levelColor ?? AppColors.gold;
    final progress = requiredPoints > 0
        ? (currentPoints / requiredPoints).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(_levelIcon(), color: color, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Уровень: $level',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$currentPoints / $requiredPoints',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'До уровня $nextLevel — ${nextLevelRequired - currentPoints} очков',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (benefits.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Ваши привилегии:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: color.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      b,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _levelIcon() {
    switch (level.toLowerCase()) {
      case 'bronze':
        return Icons.military_tech_rounded;
      case 'silver':
        return Icons.workspace_premium_rounded;
      case 'gold':
        return Icons.emoji_events_rounded;
      case 'platinum':
        return Icons.diamond_rounded;
      case 'vip':
        return Icons.king_bed_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
