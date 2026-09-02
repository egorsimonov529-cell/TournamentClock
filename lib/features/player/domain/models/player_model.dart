import '../../../../core/models/rps_rank.dart';

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
  final int rpsPoints;
  final RpsRank rpsRank;
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
    required this.rpsPoints,
    this.rpsRank = RpsRank.fish,
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
    final rpsRankCode = (json['rps_rank'] ?? json['rpsRank']) as String?;
    return PlayerProfile(
      userId: json['id'] as String? ?? '',
      login: json['login'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: (json['first_name'] ?? json['firstName']) as String?,
      lastName: (json['last_name'] ?? json['lastName']) as String?,
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
      role: json['role'] as String? ?? 'player',
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      xpToNextLevel: (json['xp_to_next_level'] as num?)?.toInt() ?? 100,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      rankPoints: (json['rank_points'] ?? json['rankPoints']) is num
          ? ((json['rank_points'] ?? json['rankPoints']) as num).toInt()
          : 0,
      rpsPoints: (json['rps_points'] ?? json['rpsPoints']) is num
          ? ((json['rps_points'] ?? json['rpsPoints']) as num).toInt()
          : 0,
      rpsRank: rpsRankCode != null ? RpsRankX.fromCode(rpsRankCode) : RpsRank.fish,
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

  /// Create PlayerProfile from API response (snake_case format)
  factory PlayerProfile.fromApiJson(Map<String, dynamic> json, dynamic authUser) {
    return PlayerProfile(
      userId: json['id'] as String? ?? authUser.id,
      login: json['login'] as String? ?? authUser.login,
      email: json['email'] as String? ?? authUser.email,
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? authUser.firstName,
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? authUser.lastName,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String? ?? authUser.avatarUrl,
      role: json['role'] as String? ?? 'player',
      level: 1,
      xp: 0,
      xpToNextLevel: 100,
      rank: 0,
      rankPoints: 0,
      rpsPoints: 0,
      rpsRank: RpsRank.fish,
      winRate: 0.0,
      totalTournaments: 0,
      totalWins: 0,
      totalPodiums: 0,
      totalProfit: 0.0,
      averageScore: 0.0,
      balance: 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : authUser.createdAt ?? DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : authUser.lastLoginAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': userId,
    'login': login,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'avatar_url': avatarUrl,
    'role': role,
    'level': level,
    'xp': xp,
    'xp_to_next_level': xpToNextLevel,
    'rank': rank,
    'rank_points': rankPoints,
    'rps_rank': rpsRank.name,
    'win_rate': winRate,
    'total_tournaments': totalTournaments,
    'total_wins': totalWins,
    'total_podiums': totalPodiums,
    'total_profit': totalProfit,
    'average_score': averageScore,
    'balance': balance,
    'created_at': createdAt.toIso8601String(),
    'last_login_at': lastLoginAt.toIso8601String(),
  };

  PlayerProfile copyWith({
    String? userId,
    String? login,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? role,
    int? level,
    int? xp,
    int? xpToNextLevel,
    int? rank,
    int? rankPoints,
    int? rpsPoints,
    RpsRank? rpsRank,
    double? winRate,
    int? totalTournaments,
    int? totalWins,
    int? totalPodiums,
    double? totalProfit,
    double? averageScore,
    double? balance,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) => PlayerProfile(
    userId: userId ?? this.userId,
    login: login ?? this.login,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    role: role ?? this.role,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
    rank: rank ?? this.rank,
    rankPoints: rankPoints ?? this.rankPoints,
    rpsPoints: rpsPoints ?? this.rpsPoints,
    rpsRank: rpsRank ?? this.rpsRank,
    winRate: winRate ?? this.winRate,
    totalTournaments: totalTournaments ?? this.totalTournaments,
    totalWins: totalWins ?? this.totalWins,
    totalPodiums: totalPodiums ?? this.totalPodiums,
    totalProfit: totalProfit ?? this.totalProfit,
    averageScore: averageScore ?? this.averageScore,
    balance: balance ?? this.balance,
    createdAt: createdAt ?? this.createdAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );
}

enum TournamentStatus { upcoming, inProgress, completed, cancelled }

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
