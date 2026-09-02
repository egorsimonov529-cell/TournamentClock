import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/achievement.dart';

class AchievementAdminCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const AchievementAdminCard({
    super.key,
    required this.achievement,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = (achievement.imageUrl ?? '').trim().isNotEmpty;
    final isUnlocked = achievement.completed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnlocked
              ? [
                  AppColors.cardGold.withValues(alpha: 0.9),
                  AppColors.card.withValues(alpha: 0.96),
                ]
              : [
                  AppColors.card.withValues(alpha: 0.92),
                  AppColors.surface.withValues(alpha: 0.98),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked ? AppColors.gold.withValues(alpha: 0.7) : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUnlocked ? AppColors.gold : AppColors.primary)
                .withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.gold.withValues(alpha: 0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked ? AppColors.gold.withValues(alpha: 0.7) : AppColors.border,
              ),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _AchievementImage(url: achievement.imageUrl!),
                  )
                : const Icon(Icons.emoji_events_rounded, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(Icons.verified_rounded, color: AppColors.gold, size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.gold.withValues(alpha: 0.12)
                        : AppColors.input,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isUnlocked ? AppColors.gold.withValues(alpha: 0.35) : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '${achievement.currentValue} / ${achievement.targetValue}',
                    style: TextStyle(
                      color: isUnlocked ? AppColors.gold : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementImage extends StatelessWidget {
  const _AchievementImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final isNetwork = url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
    final imageUrl = url.startsWith('/uploads/')
        ? '${AppConfig.apiBaseUrl.replaceAll('/api/v1', '')}$url'
        : url;
    if (isNetwork) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.emoji_events_rounded),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events_rounded),
    );
  }
}
