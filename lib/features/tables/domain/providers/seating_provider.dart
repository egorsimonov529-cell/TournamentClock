import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';

import '../models/seating_models.dart';

final seatingProvider = StateNotifierProvider<SeatingNotifier, SeatingState>((
  ref,
) {
  return SeatingNotifier();
});

class SeatingNotifier extends StateNotifier<SeatingState> {
  SeatingNotifier({SeatingState? initialState})
    : super(initialState ?? _initialState());

  static SeatingState _initialState() {
    final players = [
      Player(id: 'p1', name: 'Алексей Морозов'),
      Player(id: 'p2', name: 'Мария Вяземская'),
      Player(id: 'p3', name: 'Дмитрий Каменский'),
      Player(id: 'p4', name: 'Екатерина Орлова'),
      Player(id: 'p5', name: 'Михаил Серафим'),
      Player(id: 'p6', name: 'Павел Мельник'),
      Player(id: 'p7', name: 'Анна Волкова'),
      Player(id: 'p8', name: 'Сергей Виноградов'),
      Player(id: 'p9', name: 'Олег Семёнов'),
      Player(id: 'p10', name: 'Ирина Павлова'),
      Player(id: 'p11', name: 'Максим Белов'),
      Player(id: 'p12', name: 'Наталья Соколова'),
    ];
    List<TableSeat> seats() =>
        List.generate(8, (index) => TableSeat(number: index + 1));
    final first = seats()
      ..[0] = TableSeat(number: 1, player: players[0])
      ..[2] = TableSeat(number: 3, player: players[1])
      ..[5] = TableSeat(number: 6, player: players[2]);
    final second = seats()
      ..[1] = TableSeat(number: 2, player: players[3])
      ..[4] = TableSeat(number: 5, player: players[4]);
    return SeatingState(
      tables: [
        PokerTable(id: 't1', name: 'Стол 1', seats: first),
        PokerTable(id: 't2', name: 'Стол 2', seats: second),
      ],
      unseatedPlayers: players.sublist(5),
      selectedTableId: 't1',
    );
  }

  void selectTable(String tableId) {
    if (state.tables.any((table) => table.id == tableId)) {
      state = state.copyWith(selectedTableId: tableId);
    }
  }

  bool assignPlayer(String playerId, int seatNumber) {
    final candidates = state.unseatedPlayers.where((p) => p.id == playerId);
    if (candidates.isEmpty ||
        state.tables.any(
          (table) => table.seats.any((seat) => seat.player?.id == playerId),
        )) {
      return false;
    }
    final table = state.selectedTable;
    if (table == null) return false;
    final seatIndex = table.seats.indexWhere(
      (seat) => seat.number == seatNumber && !seat.isOccupied,
    );
    if (seatIndex < 0) return false;

    final seats = [...table.seats];
    seats[seatIndex] = seats[seatIndex].copyWith(player: candidates.first);
    _updateTable(table.copyWith(seats: seats));
    state = state.copyWith(
      unseatedPlayers: state.unseatedPlayers
          .where((p) => p.id != playerId)
          .toList(),
    );
    return true;
  }

  void releaseSeat(int seatNumber) {
    final table = state.selectedTable;
    if (table == null) return;
    final seatIndex = table.seats.indexWhere(
      (seat) => seat.number == seatNumber,
    );
    if (seatIndex < 0) return;
    final player = table.seats[seatIndex].player;
    if (player == null) return;

    final seats = [...table.seats];
    seats[seatIndex] = seats[seatIndex].copyWith(clearPlayer: true);
    _updateTable(table.copyWith(seats: seats));
    if (!state.unseatedPlayers.any((item) => item.id == player.id)) {
      state = state.copyWith(
        unseatedPlayers: [...state.unseatedPlayers, player],
      );
    }
  }

  void autoSeat() {
    final players =
        <Player>[
          ...state.tables.expand(
            (table) => table.seats
                .where((seat) => seat.player != null)
                .map((seat) => seat.player!),
          ),
          ...state.unseatedPlayers,
        ]..sort((a, b) {
          final skill = b.skillScore.compareTo(a.skillScore);
          if (skill != 0) return skill;
          final rank = b.rpsRank.index.compareTo(a.rpsRank.index);
          if (rank != 0) return rank;
          return a.id.compareTo(b.id);
        });
    final orderedTables = [...state.tables]
      ..sort((a, b) {
        final name = a.name.compareTo(b.name);
        return name != 0 ? name : a.id.compareTo(b.id);
      });
    var playerIndex = 0;
    final seatedTables = <PokerTable>[];
    for (final table in orderedTables) {
      final seats = <TableSeat>[];
      for (final seat in table.seats) {
        seats.add(
          TableSeat(
            number: seat.number,
            player: playerIndex < players.length
                ? players[playerIndex++]
                : null,
          ),
        );
      }
      seatedTables.add(table.copyWith(seats: seats));
    }
    state = state.copyWith(
      tables: seatedTables,
      unseatedPlayers: players.skip(playerIndex).toList(),
    );
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

  void addTable() {
    var suffix = state.tables.length + 1;
    var id = 't$suffix';
    while (state.tables.any((table) => table.id == id)) {
      suffix++;
      id = 't$suffix';
    }
    final table = PokerTable(
      id: id,
      name: 'Стол $suffix',
      seats: List.generate(8, (index) => TableSeat(number: index + 1)),
    );
    state = state.copyWith(
      tables: [...state.tables, table],
      selectedTableId: id,
    );
  }

  void _updateTable(PokerTable updated) {
    state = state.copyWith(
      tables: state.tables
          .map((table) => table.id == updated.id ? updated : table)
          .toList(),
    );
  }
}
