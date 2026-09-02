import '../../../../core/models/rps_rank.dart';

class AdminPlayer {
  final String id;
  final String login;
  final String name;
  final String email;
  final RpsRank rank;
  final int rpsPoints;
  final int rankPoints;
  final int rating;
  final int tournaments;
  final int wins;

  const AdminPlayer({
    required this.id,
    required this.login,
    required this.name,
    required this.email,
    required this.rank,
    required this.rpsPoints,
    required this.rankPoints,
    required this.rating,
    required this.tournaments,
    required this.wins,
  });

  factory AdminPlayer.fromJson(Map<String, dynamic> json) {
    final rpsRankCode = json['rps_rank'] as String?;
    return AdminPlayer(
      id: json['id'] as String? ?? '',
      login: json['login'] as String? ?? '',
      name: json['name'] as String? ?? json['login'] as String? ?? '',
      email: json['email'] as String? ?? '',
      rank: rpsRankCode != null ? RpsRankX.fromCode(rpsRankCode) : RpsRank.fish,
      rpsPoints: json['rps_points'] as int? ?? 0,
      rankPoints: json['rank_points'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      tournaments: json['tournaments'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
    );
  }

  AdminPlayer copyWith({
    RpsRank? rank,
    int? rpsPoints,
    int? rankPoints,
    int? rating,
  }) =>
      AdminPlayer(
        id: id,
        login: login,
        name: name,
        email: email,
        rank: rank ?? this.rank,
        rpsPoints: rpsPoints ?? this.rpsPoints,
        rankPoints: rankPoints ?? this.rankPoints,
        rating: rating ?? this.rating,
        tournaments: tournaments,
        wins: wins,
      );
}
