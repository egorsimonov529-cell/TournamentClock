import '../../../../core/models/rps_rank.dart';

enum SeatStatus {
  free,      // Свободно
  occupied,  // Занято другим игроком
  booked;    // Забронировано текущим игроком

  String get label {
    switch (this) {
      case SeatStatus.free:
        return 'Свободно';
      case SeatStatus.occupied:
        return 'Занято';
      case SeatStatus.booked:
        return 'Ваше место';
    }
  }

  static SeatStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'free':
        return SeatStatus.free;
      case 'occupied':
        return SeatStatus.occupied;
      case 'booked':
        return SeatStatus.booked;
      default:
        return SeatStatus.free;
    }
  }
}

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
    final rankCode = json['rpsRank'] as String?;
    final rank = rankCode != null ? RpsRankX.fromCode(rankCode) : RpsRank.fish;
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
  final SeatStatus status;
  final bool isBookedByMe;

  const TableSeat({
    required this.number,
    this.player,
    this.status = SeatStatus.free,
    this.isBookedByMe = false,
  });

  bool get isOccupied => player != null;

  TableSeat copyWith({
    Player? player,
    bool? clearPlayer,
    SeatStatus? status,
    bool? isBookedByMe,
  }) {
    return TableSeat(
      number: number,
      player: (clearPlayer == true) ? null : player ?? this.player,
      status: status ?? this.status,
      isBookedByMe: isBookedByMe ?? this.isBookedByMe,
    );
  }

  factory TableSeat.fromJson(Map<String, dynamic> json) {
    final playerData = json['player'] as Map<String, dynamic>?;
    Player? player;
    if (playerData != null) {
      player = Player(
        id: playerData['id'] as String,
        name: playerData['name'] as String,
      );
    }
    final statusStr = json['status'] as String? ?? 'free';
    return TableSeat(
      number: (json['number'] as num?)?.toInt() ?? 1,
      player: player,
      status: SeatStatus.fromString(statusStr),
      isBookedByMe: json['isBookedByMe'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'player': player?.toJson(),
    'status': status.name,
    'isBookedByMe': isBookedByMe,
  };
}

class PokerTable {
  final String id;
  final String name;
  final List<TableSeat> seats;

  const PokerTable({
    required this.id,
    required this.name,
    required this.seats,
  });

  int get occupiedCount => seats.where((seat) => seat.isOccupied).length;
  int get capacity => seats.length;
  int get freeSeats => seats.where((seat) => seat.status == SeatStatus.free).length;

  PokerTable copyWith({
    String? name,
    List<TableSeat>? seats,
  }) => PokerTable(
    id: id,
    name: name ?? this.name,
    seats: seats ?? this.seats,
  );
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
