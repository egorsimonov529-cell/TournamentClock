import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Карточка турнира (список)
class TournamentListItem extends StatelessWidget {
  final String name;
  final String date;
  final String time;
  final String buyIn;
  final String prizePool;
  final String? status;
  final String? guestStatus;
  final bool isCompleted;
  final VoidCallback? onRegister;
  final VoidCallback? onDetails;

  const TournamentListItem({
    super.key,
    required this.name,
    required this.date,
    required this.time,
    required this.buyIn,
    required this.prizePool,
    this.status,
    this.guestStatus,
    this.isCompleted = false,
    this.onRegister,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    status!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? AppColors.accent : AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (guestStatus != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildStatusBadge(guestStatus!),
            ),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _buildInfoItem(Icons.calendar_today_rounded, '$date, $time'),
              _buildInfoItem(Icons.monetization_on_rounded, 'Бай-ин $buyIn'),
              _buildInfoItem(Icons.emoji_events_rounded, 'Призовой $prizePool'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isCompleted)
            Row(
              children: [
                if (onRegister != null)
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Регистрация',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onRegister != null && onDetails != null)
                  const SizedBox(width: AppSpacing.sm),
                if (onDetails != null)
                  TextButton.icon(
                    onPressed: onDetails,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 0,
                      ),
                    ),
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text(
                      'Подробнее',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text) {
    final isConfirmed = text == 'Подтверждён';
    final isEliminated = text == 'Выбыл';
    final color = isEliminated
        ? Colors.redAccent
        : (isConfirmed ? AppColors.primary : AppColors.warning);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
