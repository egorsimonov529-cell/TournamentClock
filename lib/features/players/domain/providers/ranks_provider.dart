import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../models/rank_definition.dart';

final ranksProvider =
    StateNotifierProvider<RanksNotifier, AsyncValue<List<RankDefinition>>>(
      (ref) => RanksNotifier(),
    );

class RanksNotifier extends StateNotifier<AsyncValue<List<RankDefinition>>> {
  RanksNotifier() : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    try {
      final response = await ApiService().get('/admin/ranks');
      final data = response.data as List<dynamic>;
      final ranks = data
          .map((item) => RankDefinition.fromJson(item as Map<String, dynamic>))
          .toList();
      state = AsyncData(ranks);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> upsert(RankDefinition rank) async {
    final current = [...state.valueOrNull ?? const <RankDefinition>[]];
    final index = current.indexWhere((item) => item.id == rank.id);
    if (index < 0) {
      current.add(rank);
    } else {
      current[index] = rank;
    }
    current.sort((a, b) => a.minimumPoints.compareTo(b.minimumPoints));
    state = AsyncData(current);
  }

  Future<void> remove(String id) async {
    final current = [...state.valueOrNull ?? const <RankDefinition>[]]
      ..removeWhere((item) => item.id == id);
    state = AsyncData(current);
  }
}
