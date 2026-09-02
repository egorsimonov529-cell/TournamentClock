import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Карточка достижения
class AchievementCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final int progress;
  final int required;
  final bool achieved;
  final Color? accentColor;
  final String? imageUrl;

  const AchievementCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.progress = 0,
    this.required = 100,
    this.achieved = false,
    this.accentColor,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final color = achieved
        ? (accentColor ?? AppColors.gold)
        : (accentColor ?? AppColors.textSecondary);
    final progressPercent = required > 0
        ? (progress / required).clamp(0.0, 1.0)
        : 0.0;
    final hasImage = (imageUrl ?? '').trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: achieved ? AppColors.cardGold : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: achieved
              ? (accentColor ?? AppColors.gold).withValues(alpha: 0.4)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: achieved ? color.withValues(alpha: 0.12) : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: achieved ? color.withValues(alpha: 0.5) : AppColors.border,
                  ),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imageUrl!,
                          fit: BoxFit.cover,
                          color: achieved ? null : Colors.white.withValues(alpha: 0.35),
                          colorBlendMode: BlendMode.modulate,
                          errorBuilder: (_, __, ___) => Icon(
                            achieved ? icon : Icons.lock_outline_rounded,
                            color: achieved ? color : AppColors.textMuted,
                          ),
                        ),
                      )
                    : Icon(
                        achieved ? icon : Icons.lock_outline_rounded,
                        color: achieved ? color : AppColors.textMuted,
                        size: 22,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: achieved ? AppColors.white : AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (achieved)
                          Icon(Icons.verified_rounded, color: color, size: 18),
                      ],
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!achieved && required > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: progressPercent,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                color.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$progress / $required',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
