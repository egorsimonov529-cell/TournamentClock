import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/providers/tournament_clock_provider.dart';
import '../../domain/models/tournament_clock_model.dart';
import '../widgets/timer_widget.dart';
import '../widgets/blinds_card.dart';
import '../widgets/level_indicator.dart';
import '../widgets/control_buttons.dart';
import '../widgets/next_level_card.dart';
import '../widgets/tournament_info.dart';

class TournamentClockScreen extends ConsumerStatefulWidget {
  const TournamentClockScreen({super.key});

  @override
  ConsumerState<TournamentClockScreen> createState() => _TournamentClockScreenState();
}

class _TournamentClockScreenState extends ConsumerState<TournamentClockScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePauseShortcut() {
    final clockState = ref.read(tournamentClockProvider);
    final levels = ref.read(tournamentBlindLevelsProvider);

    if (FocusManager.instance.primaryFocus is EditableText) {
      return;
    }

    if (clockState.isRunning) {
      ref.read(tournamentClockProvider.notifier).togglePause();
      return;
    }

    if (levels.isNotEmpty) {
      ref.read(tournamentClockProvider.notifier).start(
        levels,
        clockState.currentLevel > 0 ? clockState.currentLevel : 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clockState = ref.watch(tournamentClockProvider);
    final clockNotifier = ref.read(tournamentClockProvider.notifier);
    final blindLevels = ref.watch(tournamentBlindLevelsProvider);

    final currentLevel = blindLevels.isEmpty
        ? null
        : blindLevels.elementAtOrNull(clockState.currentLevel.clamp(0, blindLevels.length - 1));
    final nextLevel = blindLevels.isEmpty
        ? null
        : blindLevels.elementAtOrNull((clockState.currentLevel + 1).clamp(0, blindLevels.length - 1));

    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 12.0 : 24.0;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          _togglePauseShortcut();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xff151C25),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xff2A2D35),
                    width: 1,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 700;

                    final info = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Управление таймером',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TournamentInfo(
                          name: 'Poker Club Tournament',
                          format: 'TT No-Limit',
                          players: 45,
                          maxPlayers: 100,
                          buyIn: 1000,
                          prizePool: 500000,
                          status: clockState.isRunning ? 'В игре' : 'Ожидание',
                        ),
                      ],
                    );

                    final actions = Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: () => context.push('/tv'),
                          icon: const Icon(Icons.live_tv_rounded),
                          label: const Text('Показать на ТВ'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xff163A32),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          info,
                          const SizedBox(height: 12),
                          actions,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: info),
                        const SizedBox(width: 12),
                        Flexible(child: actions),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              TimerWidget(
                time: clockNotifier.formattedTime,
                isRunning: clockState.isRunning,
                isPaused: clockState.isPaused,
              ),
              const SizedBox(height: 18),

              ControlButtons(
                isRunning: clockState.isRunning,
                isPaused: clockState.isPaused,
                onStart: () {
                  if (blindLevels.isEmpty) return;
                  clockNotifier.start(blindLevels, clockState.currentLevel > 0
                      ? clockState.currentLevel
                      : 0);
                },
                onPause: () => clockNotifier.togglePause(),
                onStop: () => clockNotifier.stop(),
                onNext: () => clockNotifier.nextLevel(blindLevels),
                onPrev: () => clockNotifier.prevLevel(blindLevels),
              ),
              const SizedBox(height: 18),

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
              const SizedBox(height: 18),

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
    );
  }
}

