import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';

class RpsSettings {
  final int ratingPerRps;

  const RpsSettings({
    required this.ratingPerRps,
  });

  factory RpsSettings.fromJson(Map<String, dynamic> json) => RpsSettings(
        ratingPerRps: json['rating_per_rps'] as int? ?? 10,
      );

  Map<String, dynamic> toJson() => {
        'rating_per_rps': ratingPerRps,
      };
}

class TournamentResult {
  final String? id;
  final String tournamentId;
  final String userId;
  final String userName;
  final int position;
  final int ratingEarned;
  final int rpsEarned;
  final int currentRating;
  final int currentRpsPoints;
  final String currentRank;

  const TournamentResult({
    this.id,
    required this.tournamentId,
    required this.userId,
    required this.userName,
    required this.position,
    required this.ratingEarned,
    required this.rpsEarned,
    required this.currentRating,
    required this.currentRpsPoints,
    required this.currentRank,
  });

  factory TournamentResult.fromJson(Map<String, dynamic> json) => TournamentResult(
        id: json['id'] as String?,
        tournamentId: json['tournament_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        userName: json['user_name'] as String? ?? '',
        position: json['position'] as int? ?? 0,
        ratingEarned: json['rating_earned'] as int? ?? 0,
        rpsEarned: json['rps_earned'] as int? ?? 0,
        currentRating: json['current_rating'] as int? ?? 0,
        currentRpsPoints: json['current_rps_points'] as int? ?? 0,
        currentRank: json['current_rank'] as String? ?? 'FISH',
      );
}

class RpsNotifier extends StateNotifier<RpsState> {
  RpsNotifier() : super(const RpsState());

  Future<void> loadSettings() async {
    try {
      final response = await ApiService().get('/rps/settings');
      if (response.data != null) {
        state = state.copyWith(
          settings: RpsSettings.fromJson(response.data as Map<String, dynamic>),
        );
      }
    } catch (e) {
      print('Ошибка загрузки настроек RPS: $e');
    }
  }

  Future<void> saveSettings(RpsSettings settings) async {
    try {
      await ApiService().post('/rps/settings', data: settings.toJson());
      state = state.copyWith(settings: settings);
    } catch (e) {
      print('Ошибка сохранения настроек RPS: $e');
      rethrow;
    }
  }

  Future<List<TournamentResult>> loadResults(String tournamentId) async {
    try {
      final response = await ApiService().get('/rps/tournaments/$tournamentId/results');
      if (response.data != null) {
        final results = (response.data as List<dynamic>)
            .map((item) => TournamentResult.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(results: results);
        return results;
      }
      return [];
    } catch (e) {
      print('Ошибка загрузки результатов турнира: $e');
      return [];
    }
  }

  Future<bool> distributeResults(String tournamentId, List<Map<String, dynamic>> results) async {
    try {
      final response = await ApiService().post('/rps/tournaments/$tournamentId/distribute', data: {
        'results': results,
      });
      
      if (response.data != null && response.data['success'] == true) {
        await loadResults(tournamentId);
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка распределения результатов: $e');
      return false;
    }
  }

  Future<bool> clearResults(String tournamentId) async {
    try {
      final response = await ApiService().delete('/rps/tournaments/$tournamentId/results');
      if (response.data != null && response.data['success'] == true) {
        state = state.copyWith(results: []);
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка очистки результатов: $e');
      return false;
    }
  }

  Future<bool> editPlayerRps(String playerId, int rpsPoints, {String? reason}) async {
    try {
      final response = await ApiService().patch('/rps/players/$playerId', data: {
        'rps_points': rpsPoints,
        'reason': reason,
      });
      
      if (response.data != null && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка изменения RPS: $e');
      return false;
    }
  }

  Future<bool> seasonReset({String? reason}) async {
    try {
      final response = await ApiService().post('/rps/season-reset', data: {
        'reason': reason,
      });
      
      if (response.data != null && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка сезонного сброса: $e');
      return false;
    }
  }
}

class RpsState {
  final RpsSettings? settings;
  final List<TournamentResult> results;

  const RpsState({
    this.settings,
    this.results = const [],
  });

  RpsState copyWith({
    RpsSettings? settings,
    List<TournamentResult>? results,
  }) => RpsState(
        settings: settings ?? this.settings,
        results: results ?? this.results,
      );
}

final rpsProvider = StateNotifierProvider<RpsNotifier, RpsState>(
  (ref) => RpsNotifier(),
);
