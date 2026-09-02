import 'dart:convert';

import '../../../core/models/rps_rank.dart';
import '../../../core/services/shared_prefs_service.dart';
import '../domain/models/rank_definition.dart';

class RankRepository {
  RankRepository(this._prefs);
  final SharedPrefsService _prefs;
  static const _key = 'rank_definitions_v1';

  Future<List<RankDefinition>> load() async {
    await _prefs.init();
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        return (jsonDecode(raw) as List)
            .map(
              (item) => RankDefinition.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      } catch (_) {}
    }
    final migrated = RpsRank.values
        .map(
          (rank) => RankDefinition(
            id: 'rps-${rank.name}',
            code: rank.name,
            name: rank.label,
            minimumPoints: rank.baseScore,
          ),
        )
        .toList();
    await save(migrated);
    return migrated;
  }

  Future<void> save(List<RankDefinition> ranks) async {
    await _prefs.setString(
      _key,
      jsonEncode(ranks.map((rank) => rank.toJson()).toList()),
    );
  }
}
