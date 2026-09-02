import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onStop,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous
        _buildIconButton(
          icon: Icons.skip_previous_rounded,
          onPressed: isRunning && !isPaused ? onPrev : null,
          color: Colors.white.withValues(alpha: 0.6),
        ),

        // Start/Pause/Stop
        if (!isRunning || isPaused)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(Icons.play_arrow_rounded, size: 36),
              ),
            ),
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: onPause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(Icons.pause_rounded, size: 36),
              ),
            ),
          ),

        // Next
        _buildIconButton(
          icon: Icons.skip_next_rounded,
          onPressed: isRunning && !isPaused ? onNext : null,
          color: Colors.white.withValues(alpha: 0.6),
        ),

        // Stop
        _buildStopButton(onPressed: isRunning ? onStop : null),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onPressed,
    required Color color,
  }) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: onPressed != null ? Colors.white : color.withValues(alpha: 0.3),
      ),
      style: IconButton.styleFrom(
        backgroundColor: onPressed != null
            ? AppColors.card
            : const Color(0xff1D232C),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStopButton({VoidCallback? onPressed}) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: const Icon(Icons.stop_rounded, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: onPressed != null
            ? AppColors.error
            : AppColors.error.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
