import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_clock/core/models/rps_rank.dart';
import 'package:tournament_clock/features/player/domain/models/player_model.dart';
import 'package:tournament_clock/features/player/presentation/widgets/player_header.dart';

void main() {
  testWidgets('header shows RPS and rating without finance controls', (
    tester,
  ) async {
    final now = DateTime(2030);
    final player = PlayerProfile(
      userId: 'u1',
      login: 'player',
      email: 'player@example.com',
      role: 'player',
      level: 1,
      xp: 0,
      xpToNextLevel: 100,
      rank: 1,
      rankPoints: 450,
      rpsPoints: 450,
      rpsRank: RpsRank.bronze,
      winRate: 0,
      totalTournaments: 0,
      totalWins: 0,
      totalPodiums: 0,
      totalProfit: 0,
      averageScore: 0,
      balance: 12500,
      createdAt: now,
      lastLoginAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1000, 600)),
          child: Scaffold(body: PlayerHeader(player: player)),
        ),
      ),
    );
    expect(find.text('RPS Bronze'), findsOneWidget);
    expect(find.text('450 rating'), findsOneWidget);
    expect(find.text('\u20bd12,500'), findsNothing);
    expect(find.text('\u0411\u0430\u043b\u0430\u043d\u0441'), findsNothing);
    expect(find.text('\u041a\u0430\u0441\u0441\u0430'), findsNothing);
    expect(
      find.text('\u041f\u043e\u043f\u043e\u043b\u043d\u0438\u0442\u044c'),
      findsNothing,
    );
  });
}
