import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../models/tournament_clock_model.dart';

const String _savedTournamentGridsKey = 'saved_tournament_grids';

final tournamentGridsProvider =
    StateNotifierProvider<TournamentGridsNotifier, List<TournamentGrid>>((ref) {
      return TournamentGridsNotifier();
    });

final selectedGridProvider =
    StateNotifierProvider<SelectedGridNotifier, TournamentGrid?>((ref) {
      return SelectedGridNotifier();
    });

class TournamentGridsNotifier extends StateNotifier<List<TournamentGrid>> {
  TournamentGridsNotifier() : super([]) {
    loadGrids();
  }

  Future<void> loadGrids() async {
    try {
      final res = await ApiService().get('/clock/grids');
      if (res.data is List) {
        final loaded = (res.data as List)
            .map((e) => TournamentGrid.fromJson(e as Map<String, dynamic>))
            .toList();
        if (loaded.isNotEmpty) {
          state = loaded;
          await _saveToLocalStorage(loaded);
          return;
        }
      }
    } catch (e) {
      print('Ошибка загрузки сеток: ');
    }

    final local = await _loadFromLocalStorage();
    if (local.isNotEmpty) {
      state = local;
      return;
    }

    if (state.isEmpty) {
      state = _defaultGridPresets();
      await _saveToLocalStorage(state);
    }
  }

  Future<void> saveGrid(TournamentGrid grid) async {
    final cleanName = grid.name.trim();
    if (cleanName.isEmpty) return;

    final normalized = grid.copyWith(name: cleanName);
    final existingIndex = state.indexWhere((g) => g.name.trim().toLowerCase() == cleanName.toLowerCase());

    final next = [...state];
    if (existingIndex >= 0) {
      next[existingIndex] = normalized;
    } else {
      next.add(normalized);
    }

    state = next;
    await _saveToLocalStorage(next);

    try {
      if (normalized.id != null) {
        await ApiService().put('/clock/grids/${normalized.id}', data: normalized.toJson());
        return;
      }
      final res = await ApiService().post('/clock/grids', data: normalized.toJson());
      if (res.data != null) {
        final created = TournamentGrid.fromJson(res.data as Map<String, dynamic>);
        state = state.map((item) => item.name.trim().toLowerCase() == cleanName.toLowerCase() && item.id == null
            ? created
            : item).toList();
        await _saveToLocalStorage(state);
      }
    } catch (_) {
      // local persistence is the real source of truth when backend is unavailable.
    }
  }

  Future<void> updateGrid(TournamentGrid grid) async {
    final normalized = grid.copyWith(name: grid.name.trim());
    final next = state.map((g) => g.id == normalized.id ? normalized : g).toList();
    state = next;
    await _saveToLocalStorage(next);

    try {
      if (normalized.id != null) {
        final res = await ApiService().put('/clock/grids/${normalized.id}', data: normalized.toJson());
        if (res.data != null) {
          final updatedGrid = TournamentGrid.fromJson(res.data as Map<String, dynamic>);
          state = state.map((g) => g.id == updatedGrid.id ? updatedGrid : g).toList();
          await _saveToLocalStorage(state);
        }
      }
    } catch (_) {
      // keep the local copy as the current working preset
    }
  }

  Future<void> deleteGrid(int id) async {
    if (state.length <= 1) return;
    final filtered = state.where((g) => g.id != id).toList();
    state = filtered;
    await _saveToLocalStorage(filtered);

    try {
      await ApiService().delete('/clock/grids/$id');
    } catch (_) {
      // ignore if backend is offline
    }
  }

  Future<List<TournamentGrid>> _loadFromLocalStorage() async {
    await SharedPrefsService().init();
    final raw = SharedPrefsService().getString(_savedTournamentGridsKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => TournamentGrid.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveToLocalStorage(List<TournamentGrid> grids) async {
    await SharedPrefsService().init();
    final payload = jsonEncode(grids.map((grid) => grid.toJson()).toList());
    await SharedPrefsService().setString(_savedTournamentGridsKey, payload);
  }

  List<TournamentGrid> _defaultGridPresets() {
    return [
      TournamentGrid(
        name: 'Classic 25/50',
        levels: [
          BlindLevel(level: 1, durationMinutes: 15, smallBlind: 25, bigBlind: 50, ante: 0),
          BlindLevel(level: 2, durationMinutes: 15, smallBlind: 50, bigBlind: 100, ante: 10),
          BlindLevel(level: 3, durationMinutes: 15, smallBlind: 100, bigBlind: 200, ante: 20),
        ],
        backgroundTheme: BackgroundTheme.dark,
      ),
      TournamentGrid(
        name: 'Turbo Night',
        levels: [
          BlindLevel(level: 1, durationMinutes: 10, smallBlind: 50, bigBlind: 100, ante: 0),
          BlindLevel(level: 2, durationMinutes: 10, smallBlind: 100, bigBlind: 200, ante: 20),
          BlindLevel(level: 3, durationMinutes: 10, smallBlind: 200, bigBlind: 400, ante: 25),
          BlindLevel(level: 4, durationMinutes: 10, smallBlind: 400, bigBlind: 800, ante: 50),
        ],
        backgroundTheme: BackgroundTheme.deepBlue,
      ),
    ];
  }
}

class SelectedGridNotifier extends StateNotifier<TournamentGrid?> {
  SelectedGridNotifier() : super(null);

  void selectGrid(TournamentGrid grid) {
    state = grid;
  }

  void clearSelection() {
    state = null;
  }
}
