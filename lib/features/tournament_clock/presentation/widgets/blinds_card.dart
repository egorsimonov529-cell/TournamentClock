import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BlindsCard extends StatelessWidget {
  final int level;
  final int smallBlind;
  final int bigBlind;
  final int ante;
  final Duration duration;
  final bool isCurrent;

  const BlindsCard({
    super.key,
    required this.level,
    required this.smallBlind,
    required this.bigBlind,
    required this.ante,
    required this.duration,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.1)
            : const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.5)
              : const Color(0xff2A2D35),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isCurrent ? 'ТЕКУЩИЙ' : 'УРОВЕНЬ $level',
                style: TextStyle(
                  color: isCurrent
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBlindInfo('SB', _formatMoney(smallBlind)),
              _buildBlindInfo('BB', _formatMoney(bigBlind)),
              _buildBlindInfo('Ante', _formatMoney(ante)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: Colors.white54,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${duration.inMinutes} мин',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (isCurrent) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Активен',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlindInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatMoney(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return '₽$value';
  }
}
