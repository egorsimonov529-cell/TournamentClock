import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_clock/core/models/rps_rank.dart';
import 'package:tournament_clock/features/player/domain/models/player_model.dart';
import 'package:tournament_clock/features/tables/domain/models/seating_models.dart';
import 'package:tournament_clock/features/tables/domain/providers/seating_provider.dart';

Map<String, dynamic> profileJson([RpsRank? rank]) => {
  'id': 'u1',
  'login': 'alice',
  'email': 'a@b.com',
  'role': 'player',
  'level': 2,
  'xp': 10,
  'xp_to_next_level': 90,
  'rank': 3,
  'rank_points': 300,
  if (rank != null) 'rps_rank': rank.name,
  'win_rate': 12.5,
  'total_tournaments': 4,
  'total_wins': 1,
  'total_podiums': 2,
  'total_profit': 42.0,
  'average_score': 7.5,
  'balance': 100.0,
  'created_at': '2024-01-02T03:04:05.000Z',
  'last_login_at': '2024-02-03T04:05:06.000Z',
};

void main() {
  group('RpsRank', () {
    test('order and scores are weak to strong', () {
      expect(RpsRank.values.map((rank) => rank.baseScore), [
        0,
        200,
        400,
        600,
        800,
        1000,
      ]);
    });

    test('parses every rank name, label, and index', () {
      for (final rank in RpsRank.values) {
        expect(RpsRankX.parse(rank.name), rank);
        expect(RpsRankX.parse(rank.label.toUpperCase()), rank);
        expect(RpsRankX.parse(rank.index), rank);
      }
    });

    test('falls back to Fish for invalid values', () {
      expect(RpsRankX.parse(null), RpsRank.fish);
      expect(RpsRankX.parse('unknown'), RpsRank.fish);
      expect(RpsRankX.parse(99), RpsRank.fish);
    });
  });

  group('PlayerProfile', () {
    test('constructor defaults to Fish', () {
      final profile = PlayerProfile(
        userId: 'u',
        login: 'l',
        email: 'e',
        role: 'player',
        level: 1,
        xp: 0,
        xpToNextLevel: 100,
        rank: 0,
        rankPoints: 0,
        winRate: 0,
        totalTournaments: 0,
        totalWins: 0,
        totalPodiums: 0,
        totalProfit: 0,
        averageScore: 0,
        balance: 0,
        createdAt: DateTime.utc(2024),
        lastLoginAt: DateTime.utc(2024),
      );
      expect(profile.rpsRank, RpsRank.fish);
    });

    test('legacy JSON without RPS falls back to Fish', () {
      expect(PlayerProfile.fromJson(profileJson()).rpsRank, RpsRank.fish);
    });

    test('JSON round trip preserves RPS and fields', () {
      final profile = PlayerProfile.fromJson(profileJson(RpsRank.pro));
      final restored = PlayerProfile.fromJson(profile.toJson());
      expect(restored.rpsRank, RpsRank.pro);
      expect(restored.userId, profile.userId);
      expect(restored.createdAt, profile.createdAt);
    });

    test('copyWith updates RPS and preserves other fields', () {
      final profile = PlayerProfile.fromJson(profileJson());
      final updated = profile.copyWith(rpsRank: RpsRank.shark);
      expect(updated.rpsRank, RpsRank.shark);
      expect(updated.login, profile.login);
    });
  });

  group('Player', () {
    test('legacy JSON defaults rank and score', () {
      final player = Player.fromJson({'id': 'p1', 'name': 'A'});
      expect(player.rpsRank, RpsRank.fish);
      expect(player.skillScore, 0);
    });

    test('JSON round trip preserves rank and score', () {
      final player = Player(id: 'p1', name: 'A', rpsRank: RpsRank.grinder);
      final restored = Player.fromJson(player.toJson());
      expect(restored.rpsRank, RpsRank.grinder);
      expect(restored.skillScore, 600);
    });
  });

  group('SeatingNotifier', () {
    SeatingState state(List<Player> players, List<int> capacities) =>
        SeatingState(
          tables: [
            for (var table = 0; table < capacities.length; table++)
              PokerTable(
                id: 't$table',
                name: 'Table $table',
                seats: [
                  for (var seat = 1; seat <= capacities[table]; seat++)
                    TableSeat(number: seat),
                ],
              ),
          ],
          unseatedPlayers: players,
          selectedTableId: capacities.isEmpty ? '' : 't0',
        );

    List<String> seatedIds(SeatingState value) => value.tables
        .expand((table) => table.seats)
        .where((seat) => seat.player != null)
        .map((seat) => seat.player!.id)
        .toList();

    Player player(String id, RpsRank rank) =>
        Player(id: id, name: id, rpsRank: rank);

    test('updatePlayerRank updates seated and unseated players', () {
      final seated = player('a', RpsRank.fish);
      final initial = state([player('b', RpsRank.fish)], [1]);
      final table = initial.tables.single.copyWith(
        seats: [TableSeat(number: 1, player: seated)],
      );
      final notifier = SeatingNotifier(
        initialState: initial.copyWith(tables: [table]),
      );
      notifier.updatePlayerRank('a', RpsRank.pro);
      notifier.updatePlayerRank('b', RpsRank.shark);
      expect(
        notifier.state.tables.single.seats.single.player!.rpsRank,
        RpsRank.pro,
      );
      expect(notifier.state.unseatedPlayers.single.rpsRank, RpsRank.shark);
    });

    test('autoSeat handles empty tables and players', () {
      final notifier = SeatingNotifier(initialState: state([], []));
      notifier.autoSeat();
      expect(notifier.state.tables, isEmpty);
      expect(notifier.state.unseatedPlayers, isEmpty);
    });

    test('autoSeat creates descending contiguous strong groups', () {
      final players = [
        player('f', RpsRank.fish),
        player('s', RpsRank.shark),
        player('p', RpsRank.pro),
        player('g', RpsRank.grinder),
      ];
      final notifier = SeatingNotifier(initialState: state(players, [2, 2]));
      notifier.autoSeat();
      expect(seatedIds(notifier.state), ['s', 'p', 'g', 'f']);
    });

    test('autoSeat breaks equal-rank ties deterministically by ID', () {
      final players = [
        player('c', RpsRank.regular),
        player('a', RpsRank.regular),
        player('b', RpsRank.regular),
      ];
      final notifier = SeatingNotifier(initialState: state(players, [3]));
      notifier.autoSeat();
      expect(seatedIds(notifier.state), ['a', 'b', 'c']);
    });

    test('autoSeat fills a partial table and clears remaining seats', () {
      final notifier = SeatingNotifier(
        initialState: state([player('a', RpsRank.pro)], [3]),
      );
      notifier.autoSeat();
      expect(seatedIds(notifier.state), ['a']);
      expect(notifier.state.tables.single.occupiedCount, 1);
    });

    test(
      'autoSeat leaves overflow players unseated when capacity is insufficient',
      () {
        final players = [
          player('a', RpsRank.shark),
          player('b', RpsRank.pro),
          player('c', RpsRank.fish),
        ];
        final notifier = SeatingNotifier(initialState: state(players, [2]));
        notifier.autoSeat();
        expect(seatedIds(notifier.state), ['a', 'b']);
        expect(notifier.state.unseatedPlayers.map((p) => p.id), ['c']);
      },
    );

    test('autoSeat works with one table', () {
      final notifier = SeatingNotifier(
        initialState: state(
          [player('b', RpsRank.fish), player('a', RpsRank.shark)],
          [2],
        ),
      );
      notifier.autoSeat();
      expect(seatedIds(notifier.state), ['a', 'b']);
      expect(notifier.state.unseatedPlayers, isEmpty);
    });
  });
}
