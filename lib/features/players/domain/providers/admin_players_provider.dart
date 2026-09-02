import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/services/api_service.dart';
import '../models/admin_player.dart';

class AdminPlayersState {
  final List<AdminPlayer> players;
  final bool isLoading;
  final String? error;
  const AdminPlayersState({this.players = const [], this.isLoading = false, this.error});
}

Map<String, dynamic>? _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry(key.toString(), item));
  return null;
}

List<dynamic> _jsonList(dynamic value) {
  if (value is List) return value;
  final map = _jsonMap(value);
  final nested = map?['data'] ?? map?['players'] ?? map?['items'];
  return nested is List ? nested : const [];
}

class AdminPlayersNotifier extends StateNotifier<AdminPlayersState> {
  AdminPlayersNotifier() : super(const AdminPlayersState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = AdminPlayersState(players: state.players, isLoading: true);
    try {
      final response = await ApiService().get('/admin/players');
      final players = _jsonList(response.data)
          .map(_jsonMap)
          .whereType<Map<String, dynamic>>()
          .map(AdminPlayer.fromJson)
          .toList();
      state = AdminPlayersState(players: players);
    } catch (error) {
      state = AdminPlayersState(
        players: state.players,
        error: error.toString(),
      );
    }
  }

  Future<void> addRating(String playerId, int delta, {String? reason}) async {
    final response = await ApiService().post(
      '/players/$playerId/rating',
      data: {'delta': delta, 'reason': reason},
    );
    final data = _jsonMap(response.data);
    final nextValue = data?['next'];
    final next = nextValue is num ? nextValue.toInt() : null;
    final rpsEarned = data?['rpsEarned'];
    final newRankCode = data?['newRank'];
    
    if (next == null) {
      throw const FormatException('Invalid rating response');
    }
    
    // Определяем новый ранг
    RpsRank newRank = RpsRank.fish;
    if (newRankCode != null) {
      newRank = RpsRankX.fromCode(newRankCode.toString());
    }
    
    state = AdminPlayersState(players: [
      for (final player in state.players)
        if (player.id == playerId)
          player.copyWith(
            rating: next,
            rpsPoints: player.rpsPoints + (rpsEarned as int? ?? 0),
            rank: newRank,
          )
        else
          player,
    ]);
    
    // Reload from server to ensure all UI components see the updated data
    await load();
  }

  void updateRank(String playerId, RpsRank rank) {
    state = AdminPlayersState(players: [
      for (final player in state.players)
        if (player.id == playerId)
          player.copyWith(rankPoints: rank.baseScore, rank: rank)
        else
          player,
    ]);
  }
}

final adminPlayersProvider =
    StateNotifierProvider<AdminPlayersNotifier, AdminPlayersState>(
      (ref) => AdminPlayersNotifier(),
    );
