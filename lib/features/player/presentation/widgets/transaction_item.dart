import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Карточка транзакции
class TransactionItem extends StatelessWidget {
  final String type;
  final String amount;
  final String date;
  final String time;
  final String description;
  final TransactionStatus status;

  const TransactionItem({
    super.key,
    required this.type,
    required this.amount,
    required this.date,
    required this.time,
    required this.description,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = type == 'Пополнение' || type == 'Бонус';
    final color = isPositive ? AppColors.accent : AppColors.textSecondary;
    final amountText = isPositive ? '+$amount' : amount;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.accent : AppColors.textSecondary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isPositive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isPositive ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor().withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        _statusText(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$date, $time',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            amountText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _statusText() {
    switch (status) {
      case TransactionStatus.completed:
        return 'Выполнено';
      case TransactionStatus.pending:
        return 'В обработке';
      case TransactionStatus.rejected:
        return 'Отклонено';
      case TransactionStatus.processing:
        return 'Обработка';
    }
  }

  Color _statusColor() {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.accent;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.warning;
      case TransactionStatus.rejected:
        return AppColors.error;
    }
  }
}

enum TransactionStatus { completed, pending, processing, rejected }
