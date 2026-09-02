import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Карточка уведомления
class NotificationCard extends StatelessWidget {
  final String title;
  final String? description;
  final String time;
  final IconData icon;
  final bool isRead;
  final Color? iconColor;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    this.description,
    required this.time,
    this.icon = Icons.notifications_rounded,
    this.isRead = false,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: isRead ? AppColors.card : AppColors.cardPrimary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isRead
                ? AppColors.border
                : (iconColor ?? AppColors.accent).withValues(alpha: 0.3),
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.accent).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: isRead
                                ? AppColors.textSecondary
                                : AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
