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
  final bool isCompleted;
  final VoidCallback? onRegister;

  const TournamentListItem({
    super.key,
    required this.name,
    required this.date,
    required this.time,
    required this.buyIn,
    required this.prizePool,
    this.status,
    this.isCompleted = false,
    this.onRegister,
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
                        ? AppColors.accent.withOpacity(0.15)
                        : AppColors.warning.withOpacity(0.15),
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
          Row(
            children: [
              _buildInfoItem(Icons.calendar_today_rounded, '$date, $time'),
              const SizedBox(width: AppSpacing.md),
              _buildInfoItem(Icons.monetization_on_rounded, 'Бай-ин $buyIn'),
              const SizedBox(width: AppSpacing.md),
              _buildInfoItem(Icons.emoji_events_rounded, 'Призовой $prizePool'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isCompleted)
            SizedBox(
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
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
