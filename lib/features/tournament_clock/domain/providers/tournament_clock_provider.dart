import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/api_service.dart';
import '../models/tournament_clock_model.dart';

final tournamentClockProvider =
    StateNotifierProvider<TournamentClockNotifier, TournamentClockState>(
      (ref) => TournamentClockNotifier(),
    );

final tournamentBlindLevelsProvider =
    StateNotifierProvider<TournamentBlindLevelsNotifier, List<BlindLevel>>((ref) {
      return TournamentBlindLevelsNotifier();
    });

class TournamentBlindLevelsNotifier extends StateNotifier<List<BlindLevel>> {
  TournamentBlindLevelsNotifier() : super([]) {
    if (AppConfig.backendMode != BackendMode.demo) {
      loadBlindLevels();
    } else {
      state = _defaultBlindLevels;
    }
  }

  static const List<BlindLevel> _defaultBlindLevels = [
    BlindLevel(level: 1, durationMinutes: 15, smallBlind: 25, bigBlind: 50, ante: 0),
    BlindLevel(level: 2, durationMinutes: 15, smallBlind: 50, bigBlind: 100, ante: 10),
    BlindLevel(level: 3, durationMinutes: 15, smallBlind: 100, bigBlind: 200, ante: 20),
    BlindLevel(level: 4, durationMinutes: 15, smallBlind: 150, bigBlind: 300, ante: 25),
    BlindLevel(level: 5, durationMinutes: 15, smallBlind: 200, bigBlind: 400, ante: 40),
    BlindLevel(level: 6, durationMinutes: 15, smallBlind: 300, bigBlind: 600, ante: 50),
    BlindLevel(level: 7, durationMinutes: 15, smallBlind: 400, bigBlind: 800, ante: 80),
    BlindLevel(level: 8, durationMinutes: 15, smallBlind: 500, bigBlind: 1000, ante: 100),
  ];

  Future<void> loadBlindLevels() async {
    try {
      final res = await ApiService().get('/clock/blind-levels');
      if (res.data is List) {
        state = (res.data as List)
            .map((e) => BlindLevel(
                  level: (e['level'] as num?)?.toInt() ?? 1,
                  durationMinutes: (e['duration_minutes'] as num?)?.toInt() ?? 15,
                  smallBlind: (e['small_blind'] as num?)?.toInt() ?? 25,
                  bigBlind: (e['big_blind'] as num?)?.toInt() ?? 50,
                  ante: (e['ante'] as num?)?.toInt() ?? 0,
                ))
            .toList();
      } else {
        state = _defaultBlindLevels;
      }
    } catch (e) {
      print('Ошибка загрузки blind levels: $e');
      state = _defaultBlindLevels;
    }
  }
}

class TournamentClockNotifier extends StateNotifier<TournamentClockState> {
  Timer? _timer;

  TournamentClockNotifier() : super(TournamentClockState.initial()) {
    // При создании — запускаем проверку таймера
  }

  void start(List<BlindLevel> levels, int initialLevel) {
    if (state.isRunning) return;

    if (levels.isEmpty) return;

    // Защита от выхода за границы массива
    final safeLevel = initialLevel.clamp(0, levels.length - 1);
    final level = levels[safeLevel];
    final timeInMinutes = level.durationMinutes;

    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      currentLevel: safeLevel,
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
    if (levels.isEmpty) return;

    final safeCurrent = state.currentLevel.clamp(0, levels.length - 1);
    if (safeCurrent >= levels.length - 1) return;

    final nextIndex = safeCurrent + 1;
    final nextLevel = levels[nextIndex];

    state = state.copyWith(
      currentLevel: nextIndex,
      timeRemaining: nextLevel.durationMinutes * 60,
    );
  }

  void prevLevel(List<BlindLevel> levels) {
    if (!state.isRunning || state.isPaused) return;
    if (levels.isEmpty) return;

    final safeCurrent = state.currentLevel.clamp(0, levels.length - 1);
    if (safeCurrent <= 0) return;

    final prevIndex = safeCurrent - 1;
    final prevLevel = levels[prevIndex];

    state = state.copyWith(
      currentLevel: prevIndex,
      timeRemaining: prevLevel.durationMinutes * 60,
    );
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Читаем актуальное состояние из провайдера
      final currentState = state;
      if (currentState.timeRemaining <= 0) {
        // Время вышло — можно автоматически перейти на следующий уровень
        state = currentState.copyWith(isRunning: false);
        _stopTimer();
        return;
      }

      state = currentState.copyWith(
        timeRemaining: currentState.timeRemaining - 1,
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
