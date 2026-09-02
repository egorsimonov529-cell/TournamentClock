import 'dart:convert';

import 'package:flutter/material.dart';
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
import 'package:tournament_clock/features/player/presentation/widgets/upcoming_tournaments.dart';

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
