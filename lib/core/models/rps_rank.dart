enum RpsRank {
  fish(0),
  bronze(200),
  silver(400),
  gold(600),
  platinum(800);

  const RpsRank(this.baseScore);
  final int baseScore;
}

extension RpsRankX on RpsRank {
  String get label =>
      const ['Fish', 'Bronze', 'Silver', 'Gold', 'Platinum'][index];

  static RpsRank parse(Object? value) {
    if (value is int && value >= 0 && value < RpsRank.values.length) {
      return RpsRank.values[value];
    }

    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return RpsRank.fish;
    }

    if (normalized == 'fish') return RpsRank.fish;
    if (normalized == 'bronze' || normalized == 'regular') return RpsRank.bronze;
    if (normalized == 'silver' || normalized == 'grinder') return RpsRank.silver;
    if (normalized == 'gold' || normalized == 'pro') return RpsRank.gold;
    if (normalized == 'platinum' || normalized == 'shark') return RpsRank.platinum;

    return RpsRank.values.firstWhere(
      (rank) => rank.name == normalized,
      orElse: () => RpsRank.fish,
    );
  }

  static RpsRank fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'FISH':
        return RpsRank.fish;
      case 'BRONZE':
        return RpsRank.bronze;
      case 'SILVER':
        return RpsRank.silver;
      case 'GOLD':
        return RpsRank.gold;
      case 'PLATINUM':
        return RpsRank.platinum;
      default:
        return RpsRank.fish;
    }
  }
}
