import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BlindLevel {
  final int level;
  final int durationMinutes;
  final int smallBlind;
  final int bigBlind;
  final int ante;
  final bool isBreak;

  const BlindLevel({
    required this.level,
    required this.durationMinutes,
    required this.smallBlind,
    required this.bigBlind,
    required this.ante,
    this.isBreak = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'durationMinutes': durationMinutes,
      'smallBlind': smallBlind,
      'bigBlind': bigBlind,
      'ante': ante,
      'isBreak': isBreak,
    };
  }

  factory BlindLevel.fromJson(Map<String, dynamic> json) {
    return BlindLevel(
      level: json['level'] as int? ?? 1,
      durationMinutes: json['durationMinutes'] as int? ?? 15,
      smallBlind: json['smallBlind'] as int? ?? 0,
      bigBlind: json['bigBlind'] as int? ?? 0,
      ante: json['ante'] as int? ?? 0,
      isBreak: json['isBreak'] as bool? ?? false,
    );
  }

  BlindLevel copyWith({
    int? level,
    int? durationMinutes,
    int? smallBlind,
    int? bigBlind,
    int? ante,
    bool? isBreak,
  }) {
    return BlindLevel(
      level: level ?? this.level,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      ante: ante ?? this.ante,
      isBreak: isBreak ?? this.isBreak,
    );
  }
}

enum BackgroundTheme {
  dark,
  gradient,
  deepBlue,
  emerald,
  gold,
}

extension BackgroundThemeExtension on BackgroundTheme {
  String get displayName {
    switch (this) {
      case BackgroundTheme.dark:
        return 'Тёмный';
      case BackgroundTheme.gradient:
        return 'Градиент';
      case BackgroundTheme.deepBlue:
        return 'Глубокий синий';
      case BackgroundTheme.emerald:
        return 'Изумрудный';
      case BackgroundTheme.gold:
        return 'Золотой';
    }
  }

  List<Color> get colors {
    switch (this) {
      case BackgroundTheme.dark:
        return [AppColors.background, AppColors.background];
      case BackgroundTheme.gradient:
        return [
          const Color(0xFF0A0E14),
          const Color(0xFF1A1D24),
        ];
      case BackgroundTheme.deepBlue:
        return [
          const Color(0xFF0A1628),
          const Color(0xFF162640),
        ];
      case BackgroundTheme.emerald:
        return [
          const Color(0xFF0A1A14),
          const Color(0xFF142E22),
        ];
      case BackgroundTheme.gold:
        return [
          const Color(0xFF1A1408),
          const Color(0xFF2A2010),
        ];
    }
  }

  Color get accentColor {
    switch (this) {
      case BackgroundTheme.dark:
        return AppColors.primary;
      case BackgroundTheme.gradient:
        return AppColors.primary;
      case BackgroundTheme.deepBlue:
        return const Color(0xFF4A9EFF);
      case BackgroundTheme.emerald:
        return AppColors.primary;
      case BackgroundTheme.gold:
        return AppColors.gold;
    }
  }
}

class TournamentClockState {
  final bool isRunning;
  final bool isPaused;
  final int currentLevel;
  final int timeRemaining;
  final int averageStack;
  final DateTime startedAt;
  final DateTime endedAt;
  final String tournamentName;
  final BackgroundTheme backgroundTheme;
  final String? tvLogoUrl;
  final Color? customBackgroundColor;

  TournamentClockState({
    required this.isRunning,
    required this.isPaused,
    required this.currentLevel,
    required this.timeRemaining,
    required this.averageStack,
    required this.startedAt,
    required this.endedAt,
    this.tournamentName = 'SUNDAY MEGA',
    this.backgroundTheme = BackgroundTheme.dark,
    this.tvLogoUrl,
    this.customBackgroundColor,
  });

  factory TournamentClockState.initial() {
    return TournamentClockState(
      isRunning: false,
      isPaused: false,
      currentLevel: 0,
      timeRemaining: 0,
      averageStack: 5000,
      startedAt: DateTime.now(),
      endedAt: DateTime.now(),
    );
  }

  TournamentClockState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? currentLevel,
    int? timeRemaining,
    int? averageStack,
    DateTime? startedAt,
    DateTime? endedAt,
    String? tournamentName,
    BackgroundTheme? backgroundTheme,
    String? tvLogoUrl,
    Color? customBackgroundColor,
  }) {
    return TournamentClockState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      currentLevel: currentLevel ?? this.currentLevel,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      averageStack: averageStack ?? this.averageStack,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      tournamentName: tournamentName ?? this.tournamentName,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      tvLogoUrl: tvLogoUrl ?? this.tvLogoUrl,
      customBackgroundColor: customBackgroundColor ?? this.customBackgroundColor,
    );
  }
}

class TournamentGrid {
  final int? id;
  final String name;
  final List<BlindLevel> levels;
  final BackgroundTheme backgroundTheme;
  final String? tvLogoUrl;

  const TournamentGrid({
    this.id,
    required this.name,
    required this.levels,
    this.backgroundTheme = BackgroundTheme.dark,
    this.tvLogoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'levels': levels.map((l) => l.toJson()).toList(),
      'backgroundTheme': backgroundTheme.name,
      'tvLogoUrl': tvLogoUrl,
    };
  }

  factory TournamentGrid.fromJson(Map<String, dynamic> json) {
    return TournamentGrid(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Новая сетка',
      levels: (json['levels'] as List<dynamic>?)
              ?.map((l) => BlindLevel.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      backgroundTheme: _parseBackground(json['backgroundTheme'] as String?),
      tvLogoUrl: json['tvLogoUrl'] as String?,
    );
  }

  static BackgroundTheme _parseBackground(String? name) {
    if (name == null) return BackgroundTheme.dark;
    try {
      return BackgroundTheme.values.byName(name);
    } catch (_) {
      return BackgroundTheme.dark;
    }
  }

  TournamentGrid copyWith({
    String? name,
    List<BlindLevel>? levels,
    BackgroundTheme? backgroundTheme,
    String? tvLogoUrl,
  }) {
    return TournamentGrid(
      id: id,
      name: name ?? this.name,
      levels: levels ?? this.levels,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      tvLogoUrl: tvLogoUrl ?? this.tvLogoUrl,
    );
  }
}
