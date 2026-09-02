import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/features/auth/domain/providers/auth_state_provider.dart';
import 'package:tournament_clock/core/models/user.dart';
import 'package:tournament_clock/features/player/presentation/pages/tournament_detail_page.dart';

void main() {
  testWidgets('switches tabs and confirms registration', (tester) async {
    final fakeUser = User(id: 'u1', login: 'tester', email: 'a@b.com', role: 'player');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAuthUserProvider.overrideWithProvider(FutureProvider<User?>((ref) async => fakeUser)),
        ],
        child: const MaterialApp(
          home: TournamentDetailPage(tournamentId: 'night-deepstack'),
        ),
      ),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Структура'));
    await tester.pump();
    expect(find.textContaining('Стартовые блайнды'), findsOneWidget);

    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();
    expect(find.text('Подтвердить'), findsOneWidget);
  });
}
