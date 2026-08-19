class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int maxPlayers;
  final double buyIn;
  final String format;
  final String status;
  final List<String> registeredPlayerIds;

  const Tournament({
    required this.id,
    required this.name,
    this.description = '',
    required this.startDate,
    required this.endDate,
    required this.maxPlayers,
    this.buyIn = 0,
    this.format = 'TT No-Limit',
    this.status = 'upcoming',
    this.registeredPlayerIds = const [],
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : DateTime.now(),
      maxPlayers: json['max_players'] as int? ?? 100,
      buyIn: (json['buy_in'] as num?)?.toDouble() ?? 0.0,
      format: json['format'] as String? ?? 'TT No-Limit',
      status: json['status'] as String? ?? 'upcoming',
      registeredPlayerIds: (json['registered_players'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'max_players': maxPlayers,
      'buy_in': buyIn,
      'format': format,
      'status': status,
      'registered_players': registeredPlayerIds,
    };
  }

  int get currentPlayers => registeredPlayerIds.length;

  bool get isFull => currentPlayers >= maxPlayers;

  String get statusDisplay {
    switch (status) {
      case 'upcoming':
        return 'Предстоящий';
      case 'inProgress':
        return 'Активный';
      case 'completed':
        return 'Завершен';
      case 'cancelled':
        return 'Отменен';
      default:
        return 'Неизвестный';
    }
  }

  String get statusColor {
    switch (status) {
      case 'upcoming':
        return '3498DB';
      case 'inProgress':
        return 'E67E22';
      case 'completed':
        return '95A5A6';
      case 'cancelled':
        return 'E74C3C';
      default:
        return '95A5A6';
    }
  }
}
