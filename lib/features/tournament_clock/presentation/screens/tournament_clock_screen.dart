import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/tournament_clock_provider.dart';
import '../../domain/models/tournament_clock_model.dart';
import '../widgets/timer_widget.dart';
import '../widgets/blinds_card.dart';
import '../widgets/level_indicator.dart';
import '../widgets/control_buttons.dart';
import '../widgets/next_level_card.dart';
import '../widgets/tournament_info.dart';

class TournamentClockScreen extends ConsumerWidget {
  const TournamentClockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockState = ref.watch(tournamentClockProvider);
    final clockNotifier = ref.read(tournamentClockProvider.notifier);

    // Моковые данные blind-уровней
    final blindLevels = const [
      BlindLevel(level: 1, durationMinutes: 15, smallBlind: 25, bigBlind: 50, ante: 0),
      BlindLevel(level: 2, durationMinutes: 15, smallBlind: 50, bigBlind: 100, ante: 10),
      BlindLevel(level: 3, durationMinutes: 15, smallBlind: 100, bigBlind: 200, ante: 20),
      BlindLevel(level: 4, durationMinutes: 15, smallBlind: 150, bigBlind: 300, ante: 25),
      BlindLevel(level: 5, durationMinutes: 15, smallBlind: 200, bigBlind: 400, ante: 40),
      BlindLevel(level: 6, durationMinutes: 15, smallBlind: 300, bigBlind: 600, ante: 50),
      BlindLevel(level: 7, durationMinutes: 15, smallBlind: 400, bigBlind: 800, ante: 80),
      BlindLevel(level: 8, durationMinutes: 15, smallBlind: 500, bigBlind: 1000, ante: 100),
    ];

    final currentLevel = blindLevels.elementAtOrNull(clockState.currentLevel);
    final nextLevel = blindLevels.elementAtOrNull(clockState.currentLevel + 1);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament Info
          TournamentInfo(
            name: 'Sunday Mega Tournament',
            format: 'TT No-Limit',
            players: 45,
            maxPlayers: 100,
            buyIn: 1000,
            prizePool: 500000,
            status: clockState.isRunning ? 'В игре' : 'Ожидание',
          ),
          const SizedBox(height: 24),

          // Timer
          TimerWidget(
            time: clockNotifier.formattedTime,
            isRunning: clockState.isRunning,
            isPaused: clockState.isPaused,
          ),
          const SizedBox(height: 24),

          // Controls
          ControlButtons(
            isRunning: clockState.isRunning,
            isPaused: clockState.isPaused,
            onStart: () {
              clockNotifier.start(blindLevels, clockState.currentLevel > 0
                  ? clockState.currentLevel
                  : 0);
            },
            onPause: () => clockNotifier.togglePause(),
            onStop: () => clockNotifier.stop(),
            onNext: () => clockNotifier.nextLevel(blindLevels),
            onPrev: () => clockNotifier.prevLevel(blindLevels),
          ),
          const SizedBox(height: 24),

          // Current & Next Level
          Row(
            children: [
              Expanded(
                child: currentLevel != null
                    ? BlindsCard(
                        level: currentLevel.level,
                        smallBlind: currentLevel.smallBlind,
                        bigBlind: currentLevel.bigBlind,
                        ante: currentLevel.ante,
                        duration: Duration(minutes: currentLevel.durationMinutes),
                        isCurrent: true,
                      )
                    : BlindsCard(
                        level: 1,
                        smallBlind: 25,
                        bigBlind: 50,
                        ante: 0,
                        duration: const Duration(minutes: 15),
                        isCurrent: false,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: nextLevel != null
                    ? NextLevelCard(
                        nextLevel: nextLevel.level,
                        smallBlind: nextLevel.smallBlind,
                        bigBlind: nextLevel.bigBlind,
                        ante: nextLevel.ante,
                        duration: nextLevel.durationMinutes,
                      )
                    : Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xff1D232C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xff2A2D35),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Последний уровень',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Level Indicator
          LevelIndicator(
            currentLevel: clockState.currentLevel,
            totalLevels: blindLevels.length,
            levels: blindLevels.map((level) {
              return BlindLevelData(
                smallBlind: level.smallBlind,
                bigBlind: level.bigBlind,
                ante: level.ante,
                duration: level.durationMinutes,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
