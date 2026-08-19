import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TimerWidget extends StatelessWidget {
  final String time;
  final bool isRunning;
  final bool isPaused;

  const TimerWidget({
    super.key,
    required this.time,
    this.isRunning = false,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaused
              ? [
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ]
              : [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPaused
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            isRunning ? 'ТЕКУЩИЙ УРОВЕНЬ' : 'ГОТОВ К СТАРТУ',
            style: TextStyle(
              color: isPaused
                  ? AppColors.warning
                  : isRunning
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            time,
            style: TextStyle(
              color: isPaused
                  ? AppColors.warning
                  : isRunning
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
              fontSize: 96,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRunning
                  ? 'Blind: 25/50 | Ante: 5'
                  : 'Нажмите START для начала турнира',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          if (isRunning) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Начало: 14:30',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
