import '../../../../core/models/rps_rank.dart';

class Player {
  final String id;
  final String name;
  final RpsRank rpsRank;
  final int skillScore;

  Player({
    required this.id,
    required this.name,
    this.rpsRank = RpsRank.fish,
    int? skillScore,
  }) : skillScore = skillScore ?? rpsRank.baseScore;

  factory Player.fromJson(Map<String, dynamic> json) {
    final rank = RpsRankX.parse(json['rpsRank']);
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      rpsRank: rank,
      skillScore: (json['skillScore'] as num?)?.toInt() ?? rank.baseScore,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rpsRank': rpsRank.label,
    'skillScore': skillScore,
  };

  Player copyWith({RpsRank? rpsRank, int? skillScore}) => Player(
    id: id,
    name: name,
    rpsRank: rpsRank ?? this.rpsRank,
    skillScore: skillScore ?? (rpsRank?.baseScore ?? this.skillScore),
  );
}

class TableSeat {
  final int number;
  final Player? player;

  const TableSeat({required this.number, this.player});

  bool get isOccupied => player != null;

  TableSeat copyWith({Player? player, bool clearPlayer = false}) {
    return TableSeat(
      number: number,
      player: clearPlayer ? null : player ?? this.player,
    );
  }
}

class PokerTable {
  final String id;
  final String name;
  final List<TableSeat> seats;

  const PokerTable({required this.id, required this.name, required this.seats});

  int get occupiedCount => seats.where((seat) => seat.isOccupied).length;
  int get capacity => seats.length;

  PokerTable copyWith({String? name, List<TableSeat>? seats}) =>
      PokerTable(id: id, name: name ?? this.name, seats: seats ?? this.seats);
}

class SeatingState {
  final List<PokerTable> tables;
  final List<Player> unseatedPlayers;
  final String selectedTableId;

  const SeatingState({
    required this.tables,
    required this.unseatedPlayers,
    required this.selectedTableId,
  });

  PokerTable? get selectedTable {
    for (final table in tables) {
      if (table.id == selectedTableId) return table;
    }
    return null;
  }

  SeatingState copyWith({
    List<PokerTable>? tables,
    List<Player>? unseatedPlayers,
    String? selectedTableId,
  }) => SeatingState(
    tables: tables ?? this.tables,
    unseatedPlayers: unseatedPlayers ?? this.unseatedPlayers,
    selectedTableId: selectedTableId ?? this.selectedTableId,
  );
}
