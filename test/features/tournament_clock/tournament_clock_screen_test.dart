import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_clock/core/theme/app_theme.dart';
import 'package:tournament_clock/features/tournament_clock/domain/models/tournament_clock_model.dart';
import 'package:tournament_clock/features/tournament_clock/domain/providers/tournament_clock_provider.dart';
import 'package:tournament_clock/features/tournament_clock/presentation/screens/tournament_clock_screen.dart';

class _ClockStub extends TournamentClockNotifier {
  _ClockStub(TournamentClockState value) {
    state = value;
  }
}

void main() {
  Future<void> pumpClock(
    WidgetTester tester,
    TournamentClockState state, {
    Size size = const Size(1280, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tournamentClockProvider.overrideWith((ref) => _ClockStub(state)),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: TournamentClockScreen()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows ready state and real first level data', (tester) async {
    await pumpClock(tester, TournamentClockState.initial());

    expect(find.text('ГОТОВ К СТАРТУ'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('25 / 50'), findsOneWidget);
    expect(find.text('СТАРТ'), findsOneWidget);
    expect(find.byTooltip('Сбросить таймер'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows paused state without overflow on a small screen', (
    tester,
  ) async {
    await pumpClock(
      tester,
      TournamentClockState(
        isRunning: true,
        isPaused: true,
        currentLevel: 1,
        timeRemaining: 599,
        startedAt: DateTime(2025),
        endedAt: DateTime(2025),
      ),
      size: const Size(390, 844),
    );

    expect(find.text('ПАУЗА'), findsOneWidget);
    expect(find.text('09:59'), findsOneWidget);
    expect(find.text('50 / 100'), findsOneWidget);
    expect(find.text('ПРОДОЛЖИТЬ'), findsOneWidget);
    expect(find.byTooltip('Предыдущий уровень'), findsOneWidget);
    expect(find.byTooltip('Следующий уровень'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
