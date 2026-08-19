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

  const AchievementCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.progress = 0,
    this.required = 100,
    this.achieved = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = achieved
        ? (accentColor ?? AppColors.gold)
        : (accentColor ?? AppColors.textSecondary);
    final progressPercent = required > 0
        ? (progress / required).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: achieved ? AppColors.cardGold : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: achieved
              ? (accentColor ?? AppColors.gold).withOpacity(0.4)
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  achieved ? icon : Icons.lock_outline_rounded,
                  color: achieved ? color : AppColors.textMuted,
                  size: 24,
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
                              color: achieved
                                  ? AppColors.white
                                  : AppColors.textMuted,
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
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
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
