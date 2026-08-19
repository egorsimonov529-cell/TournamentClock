import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager_plus/window_manager_plus.dart';

import '../../domain/providers/tournament_clock_provider.dart';
import '../../domain/models/tournament_clock_model.dart';
import '../widgets/timer_widget.dart';
import '../widgets/blinds_card.dart';
import '../widgets/level_indicator.dart';
import '../widgets/next_level_card.dart';
import '../widgets/tournament_info.dart';
import '../../../../core/services/window_manager_service.dart';

/// Окно таймера для отдельного системного окна (проектора)
class ClockWindowWidget extends ConsumerWidget {
  final WindowManagerPlus windowManager;

  const ClockWindowWidget({
    super.key,
    required this.windowManager,
  });

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

    // Масштаб в зависимости от ширины окна
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth > 1920 ? 1.3 : screenWidth > 1366 ? 1.15 : 1.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            WindowManagerService.closeClockWindow();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0E14),
                Color(0xFF1A1D24),
              ],
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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

                    // Blinds (Current + Next)
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Level Progress
                    LevelIndicator(
                      currentLevel: clockState.currentLevel,
                      totalLevels: blindLevels.length,
                      levels: blindLevels,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
