import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tournament_clock_model.dart';

final tournamentClockProvider =
    StateNotifierProvider<TournamentClockNotifier, TournamentClockState>(
  (ref) => TournamentClockNotifier(),
);

class TournamentClockNotifier extends StateNotifier<TournamentClockState> {
  Timer? _timer;

  TournamentClockNotifier() : super(TournamentClockState.initial()) {
    // При создании — запускаем проверку таймера
  }

  void start(List<BlindLevel> levels, int initialLevel) {
    if (state.isRunning) return;

    final level = levels[initialLevel];
    final timeInMinutes = level.durationMinutes;

    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      currentLevel: initialLevel,
      timeRemaining: timeInMinutes * 60,
      startedAt: DateTime.now(),
    );

    _startTimer();
  }

  void togglePause() {
    if (!state.isRunning) return;

    if (state.isPaused) {
      state = state.copyWith(isPaused: false);
      _startTimer();
    } else {
      state = state.copyWith(isPaused: true);
      _stopTimer();
    }
  }

  void stop() {
    _stopTimer();
    state = TournamentClockState.initial();
  }

  void nextLevel(List<BlindLevel> levels) {
    if (!state.isRunning || state.isPaused) return;
    if (state.currentLevel >= levels.length - 1) return;

    final nextIndex = state.currentLevel + 1;
    final nextLevel = levels[nextIndex];

    state = state.copyWith(
      currentLevel: nextIndex,
      timeRemaining: nextLevel.durationMinutes * 60,
    );
  }

  void prevLevel(List<BlindLevel> levels) {
    if (!state.isRunning || state.isPaused) return;
    if (state.currentLevel <= 0) return;

    final prevIndex = state.currentLevel - 1;
    final prevLevel = levels[prevIndex];

    state = state.copyWith(
      currentLevel: prevIndex,
      timeRemaining: prevLevel.durationMinutes * 60,
    );
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining <= 0) {
        // Время вышло — можно автоматически перейти на следующий уровень
        state = state.copyWith(isRunning: false);
        _stopTimer();
        return;
      }

      state = state.copyWith(
        timeRemaining: state.timeRemaining - 1,
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  // Форматирование времени
  String get formattedTime {
    final minutes = (state.timeRemaining / 60).floor();
    final seconds = state.timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
