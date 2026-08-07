class BlindLevel {
  final int level;
  final int durationMinutes;
  final int smallBlind;
  final int bigBlind;
  final int ante;

  const BlindLevel({
    required this.level,
    required this.durationMinutes,
    required this.smallBlind,
    required this.bigBlind,
    required this.ante,
  });
}

class TournamentClockState {
  final bool isRunning;
  final bool isPaused;
  final int currentLevel;
  final int timeRemaining; // seconds
  final DateTime startedAt;
  final DateTime endedAt;

  TournamentClockState({
    required this.isRunning,
    required this.isPaused,
    required this.currentLevel,
    required this.timeRemaining,
    required this.startedAt,
    required this.endedAt,
  });

  factory TournamentClockState.initial() {
    return TournamentClockState(
      isRunning: false,
      isPaused: false,
      currentLevel: 0,
      timeRemaining: 0,
      startedAt: DateTime.now(),
      endedAt: DateTime.now(),
    );
  }

  TournamentClockState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? currentLevel,
    int? timeRemaining,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return TournamentClockState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      currentLevel: currentLevel ?? this.currentLevel,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
