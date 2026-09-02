import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/features/players/domain/providers/admin_players_provider.dart';
import 'package:tournament_clock/features/tournament/domain/providers/tournament_provider.dart';

void main() {
  test('remote-backed providers should not bootstrap with hardcoded fake data', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(adminPlayersProvider).players, isEmpty);
    expect(container.read(tournamentProvider), isEmpty);
  });
}
