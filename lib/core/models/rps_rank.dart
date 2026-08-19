enum RpsRank {
  fish(0),
  recreational(200),
  regular(400),
  grinder(600),
  pro(800),
  shark(1000);

  const RpsRank(this.baseScore);
  final int baseScore;
}

extension RpsRankX on RpsRank {
  String get label => const [
    'Fish',
    'Recreational',
    'Regular',
    'Grinder',
    'Pro',
    'Shark',
  ][index];

  static RpsRank parse(Object? value) {
    if (value is int && value >= 0 && value < RpsRank.values.length) {
      return RpsRank.values[value];
    }
    final normalized = value?.toString().trim().toLowerCase();
    return RpsRank.values.firstWhere(
      (rank) => rank.name == normalized,
      orElse: () => RpsRank.fish,
    );
  }
}
