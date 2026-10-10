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
  final int lateRegistrationMinutes;
  final List<String> registeredPlayerIds;
  final List<String> confirmedPlayerIds;
  final List<String> eliminatedPlayerIds;

  static List<String> _normalizePlayerIds(List? raw) {
    return List<String>.from(
      (raw ?? const [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty),
    ).fold(<String>[], (result, item) {
      if (!result.contains(item)) {
        result.add(item);
      }
      return result;
    });
  }

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
    this.lateRegistrationMinutes = 0,
    this.registeredPlayerIds = const [],
    this.confirmedPlayerIds = const [],
    this.eliminatedPlayerIds = const [],
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
      lateRegistrationMinutes: (json['late_registration_minutes'] is int)
          ? json['late_registration_minutes'] as int
          : ((json['late_registration_minutes'] as num?)?.toInt() ??
              ((json['late_registration'] as bool?) == true ? 30 : 0)),
      registeredPlayerIds: _normalizePlayerIds(json['registered_players'] as List?),
      confirmedPlayerIds: _normalizePlayerIds(json['confirmed_players'] as List?),
      eliminatedPlayerIds: _normalizePlayerIds(json['eliminated_players'] as List?),
    );
  }

  Tournament copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? maxPlayers,
    double? buyIn,
    String? format,
    String? status,
    int? lateRegistrationMinutes,
    List<String>? registeredPlayerIds,
    List<String>? confirmedPlayerIds,
    List<String>? eliminatedPlayerIds,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      buyIn: buyIn ?? this.buyIn,
      format: format ?? this.format,
      status: status ?? this.status,
      lateRegistrationMinutes: lateRegistrationMinutes ?? this.lateRegistrationMinutes,
      registeredPlayerIds: _normalizePlayerIds(registeredPlayerIds ?? this.registeredPlayerIds),
      confirmedPlayerIds: _normalizePlayerIds(confirmedPlayerIds ?? this.confirmedPlayerIds),
      eliminatedPlayerIds: _normalizePlayerIds(eliminatedPlayerIds ?? this.eliminatedPlayerIds),
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
      'late_registration_minutes': lateRegistrationMinutes,
      'registered_players': registeredPlayerIds,
      'confirmed_players': confirmedPlayerIds,
      'eliminated_players': eliminatedPlayerIds,
    };
  }

  int get currentPlayers => registeredPlayerIds.length;

  bool isPlayerConfirmed(String playerId) => confirmedPlayerIds.contains(playerId);

  bool isPlayerEliminated(String playerId) => eliminatedPlayerIds.contains(playerId);

  bool canPlayerCancelRegistration(String playerId) {
    return registeredPlayerIds.contains(playerId) &&
        !isPlayerConfirmed(playerId) &&
        !isPlayerEliminated(playerId);
  }

  bool get isFull => currentPlayers >= maxPlayers;

  bool get hasLateRegistration => lateRegistrationMinutes > 0;

  DateTime get lateRegistrationDeadline =>
      startDate.add(Duration(minutes: lateRegistrationMinutes));

  bool get isRegistrationOpen {
    final now = DateTime.now();

    if (status == 'completed' || status == 'cancelled') {
      return false;
    }

    if (now.isBefore(startDate)) {
      return true;
    }

    if (hasLateRegistration && now.isBefore(lateRegistrationDeadline)) {
      return true;
    }

    return false;
  }

  String get effectiveStatus {
    final now = DateTime.now();

    if (status == 'completed') {
      return 'completed';
    }

    if (status == 'cancelled') {
      return 'cancelled';
    }

    if (now.isBefore(startDate)) {
      return 'upcoming';
    }

    if (now.isAfter(endDate)) {
      return 'completed';
    }

    return 'inProgress';
  }

  String get statusDisplay {
    switch (effectiveStatus) {
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
    switch (effectiveStatus) {
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
