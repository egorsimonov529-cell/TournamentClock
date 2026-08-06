class PlayerProfile {
  final String userId;
  final String login;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String role;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int rank;
  final int rankPoints;
  final double winRate;
  final int totalTournaments;
  final int totalWins;
  final int totalPodiums;
  final double totalProfit;
  final double averageScore;
  final double balance;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const PlayerProfile({
    required this.userId,
    required this.login,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.role,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.rank,
    required this.rankPoints,
    required this.winRate,
    required this.totalTournaments,
    required this.totalWins,
    required this.totalPodiums,
    required this.totalProfit,
    required this.averageScore,
    required this.balance,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      userId: json['id'] as String? ?? '',
      login: json['login'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'player',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      xpToNextLevel: json['xp_to_next_level'] as int? ?? 100,
      rank: json['rank'] as int? ?? 0,
      rankPoints: json['rank_points'] as int? ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0.0,
      totalTournaments: json['total_tournaments'] as int? ?? 0,
      totalWins: json['total_wins'] as int? ?? 0,
      totalPodiums: json['total_podiums'] as int? ?? 0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : DateTime.now(),
    );
  }
}

enum TournamentStatus {
  upcoming,
  inProgress,
  completed,
  cancelled,
}

class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int registrationDeadline;
  final int maxPlayers;
  final int currentPlayers;
  final double buyIn;
  final double prizePool;
  final String format;
  final TournamentStatus status;
  final String imageUrl;

  const Tournament({
    required this.id,
    required this.name,
    this.description = '',
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.buyIn,
    required this.prizePool,
    required this.format,
    required this.status,
    this.imageUrl = '',
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
      registrationDeadline: json['registration_deadline'] as int? ?? 0,
      maxPlayers: json['max_players'] as int? ?? 100,
      currentPlayers: json['current_players'] as int? ?? 0,
      buyIn: (json['buy_in'] as num?)?.toDouble() ?? 0.0,
      prizePool: (json['prize_pool'] as num?)?.toDouble() ?? 0.0,
      format: json['format'] as String? ?? 'TT',
      status: TournamentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TournamentStatus.upcoming,
      ),
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}

class TournamentEntry {
  final String id;
  final String tournamentId;
  final String tournamentName;
  final DateTime registrationDate;
  final double buyIn;
  final int? finalPosition;
  final double? winnings;
  final TournamentStatus status;

  const TournamentEntry({
    required this.id,
    required this.tournamentId,
    required this.tournamentName,
    required this.registrationDate,
    required this.buyIn,
    this.finalPosition,
    this.winnings,
    required this.status,
  });

  factory TournamentEntry.fromJson(Map<String, dynamic> json) {
    return TournamentEntry(
      id: json['id'] as String? ?? '',
      tournamentId: json['tournament_id'] as String? ?? '',
      tournamentName: json['tournament_name'] as String? ?? '',
      registrationDate: json['registration_date'] != null
          ? DateTime.parse(json['registration_date'] as String)
          : DateTime.now(),
      buyIn: (json['buy_in'] as num?)?.toDouble() ?? 0.0,
      finalPosition: json['final_position'] as int?,
      winnings: (json['winnings'] as num?)?.toDouble(),
      status: TournamentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TournamentStatus.upcoming,
      ),
    );
  }
}
