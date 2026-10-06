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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;
    final timeFontSize = isCompact ? 42.0 : 58.0;
    final labelFontSize = isCompact ? 10.0 : 12.0;
    final padding = isCompact ? 12.0 : 18.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFF141A22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Text(
                isRunning ? 'ТЕКУЩИЙ УРОВЕНЬ' : 'ГОТОВ К СТАРТУ',
                style: TextStyle(
                  color: isPaused
                      ? Colors.white.withValues(alpha: 0.7)
                      : isRunning
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.5),
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: isCompact ? 10 : 14),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  style: TextStyle(
                    color: isPaused
                        ? Colors.white.withValues(alpha: 0.8)
                        : isRunning
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                    fontSize: timeFontSize,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  isRunning
                      ? 'Blind: 25/50 | Ante: 5'
                      : 'Нажмите START для начала турнира',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ),
              if (isRunning) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Начало: 14:30',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
