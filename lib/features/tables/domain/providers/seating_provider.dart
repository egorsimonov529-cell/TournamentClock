import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/services/api_service.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';

import '../models/seating_models.dart';

final seatingProvider = StateNotifierProvider.family<SeatingNotifier, SeatingState, String>(
  (ref, tournamentId) {
    return SeatingNotifier(tournamentId: tournamentId, ref: ref);
  },
);

final seatingInitializedProvider = StateProvider<bool>((ref) => false);

class SeatingNotifier extends StateNotifier<SeatingState> {
  final String tournamentId;
  final Ref? ref;
  
  SeatingNotifier({required this.tournamentId, this.ref, SeatingState? initialState})
    : super(initialState ?? _initialState()) {
    if (initialState == null) {
      loadFromBackend();
    }
  }

  static SeatingState _initialState() {
    final players = <Player>[];
    final seats = List.generate(10, (index) => TableSeat(number: index + 1));
    return SeatingState(
      tables: [
        PokerTable(id: 'fallback', name: 'Стол 1', seats: seats),
      ],
      unseatedPlayers: players,
      selectedTableId: 'fallback',
    );
  }

  Future<void> loadFromBackend() async {
    try {
      print('[Seating] Loading tables for tournament: $tournamentId');
      
      // Загружаем таблицы из бэкенда с фильтром по турниру
      final tablesResponse = await ApiService().get(
        '/tables',
        queryParameters: {'tournament_id': tournamentId},
      );
      final tablesData = tablesResponse.data as List<dynamic>?;
      print('[Seating] Tables loaded: ${tablesData?.length ?? 0}');

      // Загружаем игроков турнира
      await _loadTournamentPlayers();

      if (tablesData != null && tablesData.isNotEmpty) {
        final allPlayers = <Player>{};
        final tables = tablesData.map((tableData) {
          final table = tableData as Map<String, dynamic>;
          final tableId = table['id'] as String;
          final tableName = table['name'] as String? ?? 'Стол';
          final seatsData = table['seats'] as List<dynamic>? ?? [];

          final seats = seatsData.map((seatData) {
            final seat = seatData as Map<String, dynamic>;
            final seatNumber = (seat['number'] as num?)?.toInt() ?? 1;
            final playerData = seat['player'] as Map<String, dynamic>?;
            Player? player;
            if (playerData != null) {
              final rankCode = playerData['rpsRank'] as String?;
              final rank = rankCode != null ? RpsRankX.fromCode(rankCode) : RpsRank.fish;
              player = Player(
                id: playerData['id'] as String,
                name: playerData['name'] as String,
                rpsRank: rank,
                skillScore: (playerData['skillScore'] as num?)?.toInt() ?? rank.baseScore,
              );
              allPlayers.add(player);
            }
            final statusStr = seat['status'] as String? ?? 'free';
            final isBookedByMe = seat['isBookedByMe'] == true;
            return TableSeat(
              number: seatNumber,
              player: player,
              status: SeatStatus.fromString(statusStr),
              isBookedByMe: isBookedByMe,
            );
          }).toList();

          return PokerTable(id: tableId, name: tableName, seats: seats);
        }).toList();

        state = state.copyWith(
          tables: tables,
          selectedTableId: tables.isNotEmpty ? tables.first.id : 'fallback',
        );
        print('[Seating] State updated with ${tables.length} tables');
      } else {
        // Если нет столов для турнира, показываем пустой список
        print('[Seating] No tables found for tournament $tournamentId');
        state = state.copyWith(tables: []);
      }
    } catch (e, stackTrace) {
      print('[Seating] Error loading tables: $e');
      print('[Seating] Stack trace: $stackTrace');
      // При ошибке показываем пустой список
      state = state.copyWith(tables: []);
    }
  }

  Future<void> _loadTournamentPlayers() async {
    if (ref == null) {
      state = state.copyWith(unseatedPlayers: []);
      return;
    }

    try {
      // Получаем турнир из провайдера
      final tournaments = ref!.read(tournamentProvider);
      final tournament = tournaments.firstWhere(
        (t) => t.id == tournamentId,
        orElse: () => throw Exception('Турнир не найден'),
      );

      final registeredPlayerIds = tournament.registeredPlayerIds.toSet();
      
      if (registeredPlayerIds.isEmpty) {
        state = state.copyWith(unseatedPlayers: []);
        return;
      }

      // Загружаем всех игроков
      final response = await ApiService().get('/players');
      final allPlayersData = response.data as List<dynamic>? ?? const [];

      // Фильтруем только зарегистрированных в турнире
      final seatedIds = state.tables
          .expand((table) => table.seats)
          .where((seat) => seat.player != null)
          .map((seat) => seat.player!.id)
          .toSet();

      final tournamentPlayers = allPlayersData
          .map((item) => item as Map<String, dynamic>)
          .where((item) => registeredPlayerIds.contains(item['id']))
          .where((item) => !seatedIds.contains(item['id']))
          .map(
            (item) => Player(
              id: item['id'] as String,
              name: item['name'] as String? ?? item['login'] as String? ?? 'Игрок',
            ),
          )
          .toList();

      state = state.copyWith(unseatedPlayers: tournamentPlayers);
    } catch (e) {
      print('Ошибка загрузки игроков турнира: $e');
      state = state.copyWith(unseatedPlayers: []);
    }
  }

  void selectTable(String tableId) {
    if (state.tables.any((table) => table.id == tableId)) {
      state = state.copyWith(selectedTableId: tableId);
    }
  }

  /// Бронирование места игроком (player-facing)
  Future<bool> bookSeat(int seatNumber) async {
    final table = state.selectedTable;
    if (table == null) return false;
    
    final seatIndex = table.seats.indexWhere(
      (seat) => seat.number == seatNumber && seat.status == SeatStatus.free,
    );
    if (seatIndex < 0) return false;

    // Отправляем на сервер
    try {
      await ApiService().post(
        '/tables/${table.id}/seats/$seatNumber/book',
      );
    } catch (e) {
      print('Ошибка при бронировании места: $e');
      return false;
    }

    // Обновляем локально
    final seats = [...table.seats];
    seats[seatIndex] = seats[seatIndex].copyWith(
      status: SeatStatus.booked,
      isBookedByMe: true,
    );
    _updateTable(table.copyWith(seats: seats));
    return true;
  }

  /// Отмена бронирования места игроком (player-facing)
  Future<bool> cancelSeat(int seatNumber) async {
    final table = state.selectedTable;
    if (table == null) return false;
    
    final seatIndex = table.seats.indexWhere(
      (seat) => seat.number == seatNumber && seat.isBookedByMe,
    );
    if (seatIndex < 0) return false;

    // Отправляем на сервер
    try {
      await ApiService().post(
        '/tables/${table.id}/seats/$seatNumber/cancel',
      );
    } catch (e) {
      print('Ошибка при отмене бронирования: $e');
      return false;
    }

    // Обновляем локально
    final seats = [...table.seats];
    seats[seatIndex] = seats[seatIndex].copyWith(
      clearPlayer: true,
      status: SeatStatus.free,
      isBookedByMe: false,
    );
    _updateTable(table.copyWith(seats: seats));
    return true;
  }

  /// Обновление состояния рассадки (перезагрузка)
  Future<void> refresh() async {
    await loadFromBackend();
  }

  Future<void> assignPlayer(String playerId, int seatNumber) async {
    final candidates = state.unseatedPlayers.where((p) => p.id == playerId);
    if (candidates.isEmpty ||
        state.tables.any(
          (table) => table.seats.any((seat) => seat.player?.id == playerId),
        )) {
      return;
    }
    final table = state.selectedTable;
    if (table == null) return;
    final seatIndex = table.seats.indexWhere(
      (seat) => seat.number == seatNumber && !seat.isOccupied,
    );
    if (seatIndex < 0) return;

    // Отправляем на сервер
    try {
      await ApiService().patch('/tables/${table.id}/seats/$seatNumber', data: {
        'user_id': playerId,
      });
    } catch (e) {
      print('Ошибка при назначении игрока на сервер: $e');
      // Продолжаем локально даже при ошибке API
    }

    final seats = [...table.seats];
    seats[seatIndex] = seats[seatIndex].copyWith(player: candidates.first);
    _updateTable(table.copyWith(seats: seats));
    state = state.copyWith(
      unseatedPlayers: state.unseatedPlayers
          .where((p) => p.id != playerId)
          .toList(),
    );
  }

  Future<bool> releaseSeat(int seatNumber) async {
    final table = state.selectedTable;
    if (table == null) return false;
    final seatIndex = table.seats.indexWhere(
      (seat) => seat.number == seatNumber,
    );
    if (seatIndex < 0) return false;
    final player = table.seats[seatIndex].player;
    if (player == null) return false;

    // Отправляем на сервер
    try {
      await ApiService().patch('/tables/${table.id}/seats/$seatNumber', data: {
        'user_id': null,
      });
    } catch (e) {
      print('Ошибка при освобождении места на сервере: $e');
      // Продолжаем локально даже при ошибке API
    }

    final seats = [...table.seats];
    seats[seatIndex] = seats[seatIndex].copyWith(clearPlayer: true);
    _updateTable(table.copyWith(seats: seats));
    if (!state.unseatedPlayers.any((item) => item.id == player.id)) {
      state = state.copyWith(
        unseatedPlayers: [...state.unseatedPlayers, player],
      );
    }
    
    return true;
  }

  Future<void> autoSeat() async {
    print('[autoSeat] Начало авторассадки');

    final playersToSeat = [...state.unseatedPlayers]
      ..sort((a, b) {
        final skillDiff = b.skillScore.compareTo(a.skillScore);
        if (skillDiff != 0) return skillDiff;
        return a.id.compareTo(b.id);
      });

    print('[autoSeat] Несевших игроков: ${playersToSeat.length}');
    if (playersToSeat.isEmpty) {
      print('[autoSeat] Нет игроков для рассадки');
      return;
    }

    final existingTables = [...state.tables];
    print('[autoSeat] Существующих столов: ${existingTables.length}');

    final availableSeats = existingTables.fold<int>(
      0,
      (sum, table) => sum + table.seats.length,
    );
    final seatedPlayers = playersToSeat.take(availableSeats).toList();
    final overflowPlayers = playersToSeat.skip(availableSeats).toList();

    print(
      '[autoSeat] Рассадка: ${seatedPlayers.length} мест, ${overflowPlayers.length} overflow',
    );

    final newTables = <PokerTable>[];
    var playerIndex = 0;

    for (final table in existingTables) {
      final seats = <TableSeat>[];
      for (final seat in table.seats) {
        if (playerIndex < seatedPlayers.length) {
          final player = seatedPlayers[playerIndex];
          seats.add(
            seat.copyWith(
              player: player,
              status: SeatStatus.occupied,
              isBookedByMe: false,
            ),
          );
          playerIndex += 1;
        } else {
          seats.add(
            seat.copyWith(
              player: null,
              status: SeatStatus.free,
              isBookedByMe: false,
            ),
          );
        }
      }

      newTables.add(
        table.copyWith(
          seats: seats,
          name: table.name,
        ),
      );
    }

    await _saveSeatingToServer(newTables);

    state = state.copyWith(
      tables: newTables,
      unseatedPlayers: overflowPlayers,
      selectedTableId: newTables.isNotEmpty ? newTables.first.id : 'fallback',
    );

    print('[autoSeat] Авторассадка завершена. Столов: ${newTables.length}');
  }

  Future<void> _saveSeatingToServer(List<PokerTable> tables) async {
    try {
      // Собираем все места со всех столов
      final allSeats = <Map<String, dynamic>>[];
      for (final table in tables) {
        for (final seat in table.seats) {
          allSeats.add({
            'tableId': table.id,
            'number': seat.number,
            'userId': seat.player?.id,
          });
        }
      }

      // Отправляем на сервер для каждого стола
      for (final table in tables) {
        final tableSeats = allSeats
            .where((s) => s['tableId'] == table.id)
            .map((s) => {
                  'number': s['number'],
                  'userId': s['userId'],
                })
            .toList();

        await ApiService().post(
          '/tables/${table.id}/seats/save-all',
          data: {'seats': tableSeats},
        );
      }
      print('[Seating] Рассадка сохранена на сервере (${tables.length} столов)');
    } catch (e) {
      print('[Seating] Ошибка при сохранении рассадки на сервере: $e');
      // Продолжаем работу локально даже при ошибке API
    }
  }

  void updatePlayerRank(String playerId, RpsRank rank) {
    Player update(Player player) =>
        player.id == playerId ? player.copyWith(rpsRank: rank) : player;
    state = state.copyWith(
      tables: state.tables
          .map(
            (table) => table.copyWith(
              seats: table.seats
                  .map(
                    (seat) => seat.player == null
                        ? seat
                        : TableSeat(
                            number: seat.number,
                            player: update(seat.player!),
                          ),
                  )
                  .toList(),
            ),
          )
          .toList(),
      unseatedPlayers: state.unseatedPlayers.map(update).toList(),
    );
  }

  Future<void> addTable() async {
    var suffix = state.tables.length + 1;
    var id = 't$suffix';
    while (state.tables.any((table) => table.id == id)) {
      suffix++;
      id = 't$suffix';
    }
    
    try {
      final response = await ApiService().post('/tables', data: {
        'name': 'Стол $suffix',
        'capacity': 10,
        'tournament_id': tournamentId,
      });
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final newId = responseData['id'] as String? ?? id;
        final tableName = responseData['name'] as String? ?? 'Стол $suffix';
        
        final table = PokerTable(
          id: newId,
          name: tableName,
          seats: List.generate(10, (index) => TableSeat(number: index + 1)),
        );
        state = state.copyWith(
          tables: [...state.tables, table],
          selectedTableId: newId,
        );
        return;
      }
    } catch (e) {
      print('Ошибка при создании стола: $e');
    }

    // Fallback to local creation
    final table = PokerTable(
      id: id,
      name: 'Стол $suffix',
      seats: List.generate(10, (index) => TableSeat(number: index + 1)),
    );
    state = state.copyWith(
      tables: [...state.tables, table],
      selectedTableId: id,
    );
  }

  Future<bool> deleteTable(String tableId) async {
    try {
      await ApiService().delete('/tables/$tableId');
      
      state = state.copyWith(
        tables: state.tables.where((t) => t.id != tableId).toList(),
        selectedTableId: state.selectedTableId == tableId
            ? (state.tables.length > 1
                ? state.tables.firstWhere((t) => t.id != tableId).id
                : 'fallback')
            : state.selectedTableId,
      );
      return true;
    } catch (e) {
      print('Ошибка при удалении стола: $e');
      return false;
    }
  }

  void _updateTable(PokerTable updated) {
    state = state.copyWith(
      tables: state.tables
          .map((table) => table.id == updated.id ? updated : table)
          .toList(),
    );
  }
}
