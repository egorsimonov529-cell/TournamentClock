import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/tournament_clock_model.dart';

class LevelIndicator extends StatelessWidget {
  final int currentLevel;
  final int totalLevels;
  final List<BlindLevel> levels;

  const LevelIndicator({
    super.key,
    required this.currentLevel,
    required this.totalLevels,
    required this.levels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'ТАБЛИЦА УРОВНЕЙ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(totalLevels, (index) {
              final level = levels[index];
              final isCurrent = index == currentLevel;
              final isPast = index < currentLevel;

              return _buildLevelChip(index, isCurrent, isPast, level);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelChip(
    int index,
    bool isCurrent,
    bool isPast,
    BlindLevel level,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary
            : isPast
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary
              : isPast
              ? AppColors.primary.withValues(alpha: 0.5)
              : const Color(0xff2A2D35),
          width: 1,
        ),
      ),
      child: Text(
        'L${index + 1}: ${level.smallBlind}/${level.bigBlind}',
        style: TextStyle(
          color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.6),
          fontSize: 11,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
