import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tournament_clock/core/constants/app_constants.dart';
import 'package:tournament_clock/core/models/user.dart';
import 'package:tournament_clock/core/services/api_service.dart';
import 'package:tournament_clock/core/services/secure_storage_service.dart';
import 'package:tournament_clock/core/services/shared_prefs_service.dart';
import 'package:tournament_clock/core/utils/form_validators.dart';
import 'package:tournament_clock/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tournament_clock/features/auth/domain/models/auth_state.dart';
import 'package:tournament_clock/features/auth/domain/providers/auth_state_provider.dart';
import 'package:tournament_clock/features/player/presentation/pages/player_dashboard_page.dart';
import 'package:tournament_clock/features/player/presentation/widgets/tournament_list_item.dart';
import 'package:tournament_clock/features/player/presentation/widgets/upcoming_tournaments.dart';
import 'package:tournament_clock/features/tournament/domain/models/tournament_model.dart';
import 'package:tournament_clock/features/tournament/domain/providers/tournament_provider.dart';
import 'package:tournament_clock/features/tournament_clock/domain/models/tournament_clock_model.dart';
import 'package:tournament_clock/features/tournament_clock/domain/providers/tournament_clock_provider.dart';
import 'package:tournament_clock/features/tournament_clock/domain/providers/tournament_grid_provider.dart';
import 'package:tournament_clock/features/tournament_clock/presentation/screens/tournament_clock_screen.dart';

void main() {
  group('FormValidators', () {
    test('accepts valid login credentials', () {
      expect(FormValidators.login('player_1'), isNull);
      expect(FormValidators.password('secret1'), isNull);
    });

    test('rejects invalid login credentials', () {
      expect(FormValidators.login('ab'), isNotNull);
      expect(FormValidators.login('bad login'), isNotNull);
      expect(FormValidators.password('123'), isNotNull);
    });

    test('validates email addresses', () {
      expect(FormValidators.email('player@example.com'), isNull);
      expect(FormValidators.email('invalid-email'), isNotNull);
    });
  });

  testWidgets('UpcomingTournaments renders without infinite width constraints', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UpcomingTournaments(onOpenTournaments: () {}),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('TournamentListItem fits narrow screens without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: TournamentListItem(
                name: 'Night Deepstack',
                date: '15 авг',
                time: '21:00',
                buyIn: '2 000 ₽',
                prizePool: '150 000 ₽',
                status: 'Регистрация',
                onRegister: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('TournamentListItem renders a details action when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              child: TournamentListItem(
                name: 'Night Deepstack',
                date: '15 авг',
                time: '21:00',
                buyIn: '2 000 ₽',
                prizePool: '150 000 ₽',
                status: 'Регистрация',
                onRegister: () {},
                onDetails: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Подробнее'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TournamentListItem shows guest status badge when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              child: TournamentListItem(
                name: 'Night Deepstack',
                date: '15 авг',
                time: '21:00',
                buyIn: '2 000 ₽',
                prizePool: '150 000 ₽',
                status: 'Регистрация',
                guestStatus: 'Подтверждён',
                onRegister: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Подтверждён'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tournament clock exposes TV action and no longer has a settings dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: const TournamentClockScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Показать на ТВ'), findsOneWidget);
    expect(find.text('Настройки'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('Tournament clock can resume from pause state', () {
    final notifier = TournamentClockNotifier();
    final levels = [
      BlindLevel(level: 1, durationMinutes: 1, smallBlind: 25, bigBlind: 50, ante: 0),
      BlindLevel(level: 2, durationMinutes: 2, smallBlind: 50, bigBlind: 100, ante: 10),
    ];

    notifier.start(levels, 0);
    expect(notifier.state.isRunning, isTrue);
    expect(notifier.state.isPaused, isFalse);

    notifier.togglePause();
    expect(notifier.state.isPaused, isTrue);

    notifier.start(levels, 0);
    expect(notifier.state.isRunning, isTrue);
    expect(notifier.state.isPaused, isFalse);
  });

  test('Tournament state removes duplicate player IDs and keeps pending cancellation allowed', () {
    final tournament = Tournament.fromJson({
      'id': 't-1',
      'name': 'Night Test',
      'description': '',
      'start_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'end_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      'max_players': 10,
      'buy_in': 2000,
      'format': 'TT No-Limit',
      'status': 'upcoming',
      'registered_players': ['p1', 'p1', 'p2'],
      'confirmed_players': ['p2'],
      'eliminated_players': [],
    });

    expect(tournament.registeredPlayerIds, ['p1', 'p2']);
    expect(tournament.canPlayerCancelRegistration('p1'), isTrue);
    expect(tournament.isPlayerConfirmed('p1'), isFalse);
  });

  test('Tournament status update preserves player sync data while changing status', () {
    final notifier = TournamentNotifier(autoLoad: false)
      ..state = [
        Tournament.fromJson({
          'id': 't-status',
          'name': 'Sync Risk Check',
          'description': '',
          'start_date': DateTime.now().toIso8601String(),
          'end_date': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'max_players': 50,
          'buy_in': 1000,
          'format': 'TT No-Limit',
          'status': 'inProgress',
          'registered_players': ['p1', 'p2'],
          'confirmed_players': ['p1'],
          'eliminated_players': ['p3'],
        }),
      ];

    notifier.updateStatus('t-status', 'completed');

    expect(notifier.state.first.status, 'completed');
    expect(notifier.state.first.registeredPlayerIds, ['p1', 'p2']);
    expect(notifier.state.first.confirmedPlayerIds, ['p1']);
    expect(notifier.state.first.eliminatedPlayerIds, ['p3']);
  });

  test('Tournament creation adds the new item to state immediately', () async {
    final notifier = TournamentNotifier(autoLoad: false);
    final tournament = Tournament(
      id: 'new-tournament',
      name: 'New Tour',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      maxPlayers: 50,
      buyIn: 1000,
      format: 'TT No-Limit',
      status: 'upcoming',
    );

    await notifier.addTournament(tournament);

    expect(notifier.state.any((item) => item.id == 'new-tournament'), isTrue);
  });

  test('Failed tournament refresh keeps the current list instead of wiping it', () async {
    final notifier = TournamentNotifier(autoLoad: false)
      ..state = [
        Tournament(
          id: 'existing',
          name: 'Existing Tour',
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 2)),
          maxPlayers: 30,
          buyIn: 1000,
          format: 'TT No-Limit',
          status: 'upcoming',
        ),
      ];

    await notifier.load();

    expect(notifier.state.isNotEmpty, isTrue);
    expect(notifier.state.first.id, 'existing');
  });

  test('Tournament grids can be saved and selected as presets', () async {
    SharedPreferences.setMockInitialValues({});

    final gridsNotifier = TournamentGridsNotifier();
    final selectedNotifier = SelectedGridNotifier();
    final levels = [
      BlindLevel(level: 1, durationMinutes: 15, smallBlind: 25, bigBlind: 50, ante: 0),
      BlindLevel(level: 2, durationMinutes: 15, smallBlind: 50, bigBlind: 100, ante: 10),
    ];

    await gridsNotifier.saveGrid(
      TournamentGrid(
        name: 'Night Turbo',
        levels: levels,
        backgroundTheme: BackgroundTheme.deepBlue,
      ),
    );

    expect(gridsNotifier.state.length, 1);
    expect(gridsNotifier.state.first.name, 'Night Turbo');

    selectedNotifier.selectGrid(gridsNotifier.state.first);
    expect(selectedNotifier.state?.name, 'Night Turbo');
  });

  testWidgets('Player dashboard shows active tournament card for confirmed registered player', (tester) async {
    final tournament = Tournament.fromJson({
      'id': 't1',
      'name': 'Night Deepstack',
      'description': '',
      'start_date': DateTime.now().toIso8601String(),
      'end_date': DateTime.now().toIso8601String(),
      'max_players': 100,
      'buy_in': 2000,
      'format': 'TT No-Limit',
      'status': 'upcoming',
      'registered_players': ['player-1'],
      'confirmed_players': ['player-1'],
      'eliminated_players': [],
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tournamentProvider.overrideWith(
            (ref) => TournamentNotifier(autoLoad: false)..state = [tournament],
          ),
          currentAuthUserProvider.overrideWith(
            (ref) => Future.value(
              User(
                id: 'player-1',
                login: 'player_1',
                email: 'player_1@test.com',
                role: 'player',
                firstName: 'Игрок',
                lastName: 'Первый',
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: PlayerDashboardPage()),
      ),
    );
    await tester.pump();

    final renderedTexts = tester.allWidgets
        .whereType<Text>()
        .map((widget) => widget.data)
        .whereType<String>()
        .toList();

    expect(renderedTexts.any((text) => text.contains('Night Deepstack')), isTrue);
    expect(renderedTexts.any((text) => text.contains('Активный турнир')), isTrue);
    expect(tester.takeException(), isNull);
  });

  test('confirmed guests cannot cancel registration and eliminated guests are marked', () {
    final tournament = Tournament.fromJson({
      'id': 't1',
      'name': 'Night Deepstack',
      'description': '',
      'start_date': DateTime.now().toIso8601String(),
      'end_date': DateTime.now().toIso8601String(),
      'max_players': 100,
      'buy_in': 2000,
      'format': 'TT No-Limit',
      'status': 'upcoming',
      'registered_players': ['p1', 'p2'],
      'confirmed_players': ['p1'],
      'eliminated_players': ['p2'],
    });

    expect(tournament.isPlayerConfirmed('p1'), isTrue);
    expect(tournament.canPlayerCancelRegistration('p1'), isFalse);
    expect(tournament.isPlayerEliminated('p2'), isTrue);
  });

  test('late registration remains open for a configured window after start time', () {
    final now = DateTime.now();
    final tournament = Tournament.fromJson({
      'id': 't2',
      'name': 'Late Reg Turbo',
      'description': '',
      'start_date': now.subtract(const Duration(minutes: 10)).toIso8601String(),
      'end_date': now.add(const Duration(hours: 2)).toIso8601String(),
      'max_players': 50,
      'buy_in': 1000,
      'format': 'TT No-Limit',
      'status': 'inProgress',
      'late_registration_minutes': 45,
      'registered_players': ['p1'],
    });

    expect(tournament.hasLateRegistration, isTrue);
    expect(tournament.isRegistrationOpen, isTrue);

    final closedTournament = Tournament.fromJson({
      'id': 't3',
      'name': 'No Late Reg',
      'description': '',
      'start_date': now.subtract(const Duration(minutes: 10)).toIso8601String(),
      'end_date': now.add(const Duration(hours: 2)).toIso8601String(),
      'max_players': 50,
      'buy_in': 1000,
      'format': 'TT No-Limit',
      'status': 'inProgress',
      'late_registration_minutes': 0,
      'registered_players': ['p1'],
    });

    expect(closedTournament.isRegistrationOpen, isFalse);
  });

  test('auth state restores the saved user session on startup', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.rememberMeKey: true,
      AppConstants.demoSessionUserKey: jsonEncode(
        User(
          id: 'demo-player',
          login: 'player_1',
          email: 'player_1@pokerclub.demo',
          role: 'player',
          firstName: 'Игрок',
          lastName: 'Первый',
        ).toJson(),
      ),
    });

    final repo = AuthRepositoryImpl(
      apiService: ApiService(),
      secureStorage: SecureStorageService(),
      sharedPrefs: SharedPrefsService(),
      isDemoMode: true,
    );

    final notifier = AuthStateNotifier(repository: repo);
    await notifier.checkInitialSession();

    expect(notifier.state.status, AuthStatus.authenticated);
    expect(notifier.state.user?.login, 'player_1');
  });
}
