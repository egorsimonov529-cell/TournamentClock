import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/seating_websocket_service.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
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
  final Map<String, bool> _lockedSeats = {}; // "tableId-seatNumber" -> locked

  SeatingNotifier({required this.tournamentId, this.ref, SeatingState? initialState})
    : super(initialState ?? _initialState()) {
    if (initialState == null) {
      loadFromBackend();
      // Подписываемся на WebSocket события
      _subscribeToWebSocket();
    }
  }

  void _subscribeToWebSocket() {
    try {
      final wsService = ref!.read(seatingWebSocketProvider);
      wsService.joinTournament(tournamentId);
      // Регистрируем callback для real-time обновления
      wsService.onSeatingUpdate = () {
        print('[Seating] WebSocket update received, refreshing...');
        refresh();
      };
      print('[Seating] Subscribed to WebSocket for tournament: $tournamentId');
    } catch (e) {
      print('[Seating] WebSocket subscription failed: $e');
    }
  }

  @override
  void dispose() {
    // Отписываемся от WebSocket
    try {
      final wsService = ref!.read(seatingWebSocketProvider);
      wsService.leaveTournament(tournamentId);
      // Убираем callback
      wsService.onSeatingUpdate = null;
    } catch (e) {
      // Ignore
    }
    super.dispose();
  }

  void _lockSeat(String tableId, int seatNumber) {
    _lockedSeats['$tableId-$seatNumber'] = true;
  }

  void _unlockSeat(String tableId, int seatNumber) {
    _lockedSeats.remove('$tableId-$seatNumber');
  }

  bool _isSeatLocked(String tableId, int seatNumber) {
    return _lockedSeats.containsKey('$tableId-$seatNumber');
  }

  /// Проверка, заблокировано ли место (для UI)
  bool isSeatLocked(String tableId, int seatNumber) {
    return _isSeatLocked(tableId, seatNumber);
  }

  /// Получение всех заблокированных мест
  Set<String> get lockedSeatsKeys => _lockedSeats.keys.toSet();

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
                login: playerData['login'] as String? ?? playerData['name'] as String? ?? 'Игрок',
                nickname: playerData['nickname'] as String?,
                name: playerData['name'] as String?,
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
        print('[Seating] No registered players for tournament $tournamentId');
        state = state.copyWith(unseatedPlayers: []);
        return;
      }

      print('[Seating] Registered players: ${registeredPlayerIds.length}');

      // Загружаем зарегистрированных игроков турнира напрямую с бэкенда
      final response = await ApiService().get(
        '/tournaments/$tournamentId/registered-players',
      );

      List<Player> tournamentPlayers = [];
      
      if (response.data is List) {
        final playersData = response.data as List<dynamic>;
        
        // Получаем уже seated IDs
        final seatedIds = state.tables
            .expand((table) => table.seats)
            .where((seat) => seat.player != null)
            .map((seat) => seat.player!.id)
            .toSet();

        tournamentPlayers = playersData
            .map((item) => item as Map<String, dynamic>)
            .where((item) => !seatedIds.contains(item['id']))
            .map(
              (item) => Player(
                id: item['id'] as String,
                login: item['login'] as String? ?? item['name'] as String? ?? 'Игрок',
                name: item['name'] as String?,
              ),
            )
            .toList();
      }

      print('[Seating] Loaded ${tournamentPlayers.length} unseated players');
      state = state.copyWith(unseatedPlayers: tournamentPlayers);
    } catch (e, stackTrace) {
      print('[Seating] Error loading tournament players: $e');
      print('[Seating] Stack trace: $stackTrace');
      
      // Fallback: пробуем загрузить всех игроков и фильтруем локально
      try {
        final response = await ApiService().get('/players');
        final allPlayersData = response.data as List<dynamic>? ?? const [];
        
        final tournaments = ref!.read(tournamentProvider);
        final tournament = tournaments.firstWhere(
          (t) => t.id == tournamentId,
          orElse: () => throw Exception('Турнир не найден'),
        );
        
        final registeredPlayerIds = tournament.registeredPlayerIds.toSet();
        
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
                login: item['login'] as String? ?? item['name'] as String? ?? 'Игрок',
                name: item['name'] as String?,
              ),
            )
            .toList();

        print('[Seating] Fallback loaded ${tournamentPlayers.length} players');
        state = state.copyWith(unseatedPlayers: tournamentPlayers);
      } catch (fallbackError) {
        print('[Seating] Fallback also failed: $fallbackError');
        state = state.copyWith(unseatedPlayers: []);
      }
    }
  }

  void selectTable(String tableId) {
    if (state.tables.any((table) => table.id == tableId)) {
      state = state.copyWith(selectedTableId: tableId);
    }
  }

  /// Бронирование места игроком (player-facing)
  /// С seat locking + optimistic update + rollback on failure
  Future<bool> bookSeat(int seatNumber) async {
    // Always use selectedTableId directly, not state.selectedTable
    final selectedTable = state.tables.firstWhere(
      (t) => t.id == state.selectedTableId,
      orElse: () => state.tables.firstOrNull ?? PokerTable(
        id: 'fallback',
        name: 'Стол 1',
        seats: List.generate(10, (index) => TableSeat(number: index + 1)),
      ),
    );
    
    if (selectedTable.id == 'fallback' && state.tables.isNotEmpty) {
      // Fallback - use first available table
      state = state.copyWith(selectedTableId: state.tables.first.id);
      return bookSeat(seatNumber); // Retry with correct table
    }
    
    final seatIndex = selectedTable.seats.indexWhere(
      (seat) => seat.number == seatNumber && seat.status == SeatStatus.free,
    );
    if (seatIndex < 0) return false;

    final actualTableId = selectedTable.id;

    // Lock seat to prevent double-clicks
    _lockSeat(actualTableId, seatNumber);

    // Save previous state for rollback
    final previousTables = state.tables;
    final previousSelectedTableId = state.selectedTableId;

    // Если используется fallback-стол, используем первый доступный стол
    if (selectedTable.id == 'fallback' && state.tables.isNotEmpty) {
      state = state.copyWith(selectedTableId: actualTableId);
      print('[Seating] Using existing table: $actualTableId');
    } else if (selectedTable.id == 'fallback') {
      // Если столов нет — создаём новый
      try {
        print('[Seating] Creating real table for tournament: $tournamentId');
        final createTableResponse = await ApiService().post('/tables', data: {
          'name': 'Стол 1',
          'capacity': 10,
          'tournament_id': tournamentId,
        });
        
        if (createTableResponse.data is Map<String, dynamic>) {
          final responseData = createTableResponse.data as Map<String, dynamic>;
          final newId = responseData['id'] as String;
          final tableName = responseData['name'] as String? ?? 'Стол 1';
          
          final newTable = PokerTable(
            id: newId,
            name: tableName,
            seats: List.generate(10, (index) => TableSeat(number: index + 1)),
          );
          state = state.copyWith(
            tables: [...state.tables, newTable],
            selectedTableId: newId,
          );
          print('[Seating] Table created with ID: $newId');
        } else {
          print('[Seating] Error creating table: invalid response');
          _unlockSeat(actualTableId, seatNumber);
          return false;
        }
      } catch (e) {
        print('[Seating] Ошибка при создании стола: $e');
        _unlockSeat(actualTableId, seatNumber);
        return false;
      }
    }

    // Проверяем, зарегистрирован ли игрок на турнир
    if (ref != null) {
      try {
        final tournaments = ref!.read(tournamentProvider);
        final tournament = tournaments.firstWhere(
          (t) => t.id == tournamentId,
          orElse: () => throw Exception('Турнир не найден'),
        );

        final authState = ref!.read(currentAuthUserProvider);
        final user = authState.valueOrNull;
        if (user == null) {
          print('Пользователь не авторизован');
          _unlockSeat(actualTableId, seatNumber);
          return false;
        }

        print('[Seating] User ID: ${user.id}');
        print('[Seating] Tournament ID: $tournamentId');
        print('[Seating] Registered player IDs: ${tournament.registeredPlayerIds}');
        
        if (!tournament.registeredPlayerIds.contains(user.id)) {
          print('Игрок не зарегистрирован на турнир');
          _unlockSeat(actualTableId, seatNumber);
          return false;
        }

        if (tournament.isPlayerEliminated(user.id)) {
          print('Игрок выбыл из турнира');
          _unlockSeat(actualTableId, seatNumber);
          return false;
        }
      } catch (e) {
        print('Ошибка проверки регистрации: $e');
        _unlockSeat(actualTableId, seatNumber);
        return false;
      }
    }

    // Обновляем локально оптимистично (optimistic update)
    final updatedTable = state.tables.firstWhere(
      (t) => t.id == actualTableId,
      orElse: () => selectedTable,
    );
    final seats = [...updatedTable.seats];
    seats[seatIndex] = seats[seatIndex].copyWith(
      status: SeatStatus.booked,
      isBookedByMe: true,
    );
    _updateTable(updatedTable.copyWith(seats: seats));
    print('[Seating] Optimistic booking for seat $seatNumber at table $actualTableId');

    // Отправляем на сервер
    try {
      print('[Seating] Booking seat $seatNumber at table $actualTableId');
      final response = await ApiService().post(
        '/tables/$actualTableId/seats/$seatNumber/book',
      );
      print('[Seating] Booking response: ${response.data}');
      
      // Success — keep optimistic update, unlock seat
      _unlockSeat(actualTableId, seatNumber);
      return true;
    } catch (e, stack) {
      print('[Seating] ERROR booking seat: $e');
      print('[Seating] Error type: ${e.runtimeType}');
      print('[Seating] Stack trace: $stack');
      if (e is DioException) {
        print('[Seating] DioException type: ${e.type}');
        print('[Seating] Status code: ${e.response?.statusCode}');
        print('[Seating] Response data: ${e.response?.data}');
        print('[Seating] Response headers: ${e.response?.headers}');
        print('[Seating] Request data: ${e.requestOptions.data}');
        print('[Seating] Request path: ${e.requestOptions.path}');
        final errorMessage = e.response?.data?['message'];
        if (errorMessage != null) {
          print('[Seating] Server error message: $errorMessage');
        }
      }
      
      // Rollback optimistic update on failure
      print('[Seating] Rolling back booking for seat $seatNumber');
      state = SeatingState(
        tables: previousTables,
        unseatedPlayers: state.unseatedPlayers,
        selectedTableId: previousSelectedTableId,
      );
      _unlockSeat(actualTableId, seatNumber);
      return false;
    }
  }

  /// Отмена бронирования места игроком (player-facing)
  /// С seat locking + optimistic update + rollback on failure
  Future<bool> cancelSeat(int seatNumber) async {
    // Always use selectedTableId directly
    final selectedTable = state.tables.firstWhere(
      (t) => t.id == state.selectedTableId,
      orElse: () => PokerTable(
        id: 'fallback',
        name: 'Стол 1',
        seats: List.generate(10, (index) => TableSeat(number: index + 1)),
      ),
    );
    
    final seatIndex = selectedTable.seats.indexWhere(
      (seat) => seat.number == seatNumber && seat.isBookedByMe,
    );
    if (seatIndex < 0) return false;

    final actualTableId = selectedTable.id;
    
    // Lock seat to prevent double-clicks
    _lockSeat(actualTableId, seatNumber);
    
    // Save previous state for rollback
    final previousTables = state.tables;
    
    // Обновляем локально оптимистично (optimistic update)
    final seats = [...selectedTable.seats];
    seats[seatIndex] = seats[seatIndex].copyWith(
      clearPlayer: true,
      status: SeatStatus.free,
      isBookedByMe: false,
    );
    _updateTable(selectedTable.copyWith(seats: seats));
    print('[Seating] Optimistic cancel for seat $seatNumber at table $actualTableId');

    // Отправляем на сервер
    try {
      final response = await ApiService().post(
        '/tables/$actualTableId/seats/$seatNumber/cancel',
      );
      print('[Seating] Cancel response: $response');
      
      // Success — keep optimistic update, unlock seat
      _unlockSeat(actualTableId, seatNumber);
      return true;
    } catch (e) {
      print('Ошибка при отмене бронирования: $e');
      
      // Rollback optimistic update on failure
      print('[Seating] Rolling back cancel for seat $seatNumber');
      state = SeatingState(
        tables: previousTables,
        unseatedPlayers: state.unseatedPlayers,
        selectedTableId: state.selectedTableId,
      );
      _unlockSeat(actualTableId, seatNumber);
      return false;
    }
  }

  /// Обновление состояния рассадки (перезагрузка)
  Future<void> refresh() async {
    await loadFromBackend();
  }

  Future<void> assignPlayer(String playerId, int seatNumber) async {
    final candidates = state.unseatedPlayers.where((p) => p.id == playerId);
    if (candidates.isEmpty) return;

    // Проверяем, нет ли уже игрока за другим столом
    if (state.tables.any(
      (table) => table.seats.any((seat) => seat.player?.id == playerId),
    )) {
      print('Игрок уже занят за другим столом');
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
