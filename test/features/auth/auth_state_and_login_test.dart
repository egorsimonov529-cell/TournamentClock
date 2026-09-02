import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_clock/core/models/auth_exception.dart';
import 'package:tournament_clock/core/models/auth_response.dart';
import 'package:tournament_clock/core/models/user.dart';
import 'package:tournament_clock/core/widgets/app_button.dart';
import 'package:tournament_clock/features/auth/domain/models/auth_state.dart';
import 'package:tournament_clock/features/auth/domain/models/demo_session.dart';
import 'package:tournament_clock/app/router.dart';
import 'package:tournament_clock/features/auth/domain/providers/auth_state_provider.dart';
import 'package:tournament_clock/features/auth/domain/repositories/auth_repository.dart';
import 'package:tournament_clock/features/auth/presentation/widgets/login_form.dart';

const repoUser = User(
  id: 'player-1',
  login: 'player@example.com',
  email: 'player@example.com',
  role: 'player',
);

class FakeAuthRepository implements AuthRepository {
  AuthException? registerError;
  DemoSession restoredSession = const DemoSession.anonymous();
  bool didLogout = false;

  AuthResponse get _response => const AuthResponse(
    accessToken: 'access',
    refreshToken: 'refresh',
    user: User(
      id: 'player-1',
      login: 'player@example.com',
      email: 'player@example.com',
      role: 'player',
    ),
  );

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    if (registerError != null) throw registerError!;
    return _response;
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    throw const OAuthUnavailableException();
  }

  @override
  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async => _response;

  @override
  Future<AuthResponse?> autoLogin() async => null;
  @override
  Future<User?> checkSession() async => null;
  @override
  Future<void> clearAll() async {}
  @override
  Future<User?> getCurrentUser() async => null;
  @override
  Future<void> logout() async {
    didLogout = true;
  }

  @override
  Future<DemoSession> restoreSession() async => restoredSession;
  @override
  Future<AuthResponse> refreshToken({required String refreshToken}) async =>
      _response;
}

void main() {
  group('auth redirects', () {
    const anonymous = AuthState(status: AuthStatus.anonymous);
    const player = AuthState(status: AuthStatus.authenticated, user: repoUser);
    const admin = AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 'admin-1',
        login: 'admin',
        email: 'admin@pokerclub.demo',
        role: 'admin',
      ),
    );

    test('anonymous users are sent to login', () {
      expect(authRedirect(anonymous, '/dashboard'), '/login');
      expect(authRedirect(anonymous, '/login'), isNull);
    });

    test('player and admin role guards redirect without loops', () {
      expect(authRedirect(player, '/dashboard'), '/user');
      expect(authRedirect(player, '/user'), isNull);
      expect(authRedirect(admin, '/user'), '/dashboard');
      expect(authRedirect(admin, '/dashboard'), isNull);
    });
  });

  group('AuthStateNotifier', () {
    test('startup does not auto-authenticate from a saved session', () async {
      final repo = FakeAuthRepository()
        ..restoredSession = DemoSession.authenticated(repoUser);
      final notifier = AuthStateNotifier(repository: repo);

      await notifier.checkInitialSession();
      expect(notifier.state.status, AuthStatus.anonymous);
    });

    test('restore, login, and logout update state', () async {
      final repo = FakeAuthRepository()
        ..restoredSession = DemoSession.authenticated(repoUser);
      final notifier = AuthStateNotifier(repository: repo);

      await notifier.checkInitialSession();
      expect(notifier.state.status, AuthStatus.anonymous);

      expect(
        await notifier.login(login: 'player', password: 'secret123'),
        isTrue,
      );
      expect(notifier.state.userRole, 'player');

      await notifier.logout();
      expect(repo.didLogout, isTrue);
      expect(notifier.state.status, AuthStatus.anonymous);
    });

    test('register sets player authenticated state', () async {
      final notifier = AuthStateNotifier(repository: FakeAuthRepository());
      final success = await notifier.register(
        name: 'Player',
        email: 'player@example.com',
        password: 'secret123',
        acceptedTerms: true,
      );
      expect(success, isTrue);
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.userRole, 'player');
    });

    test('register error is exposed in state', () async {
      final repo = FakeAuthRepository()
        ..registerError = const ValidationException(
          message: 'Email занят',
          fieldErrors: {'email': 'Email занят'},
        );
      final notifier = AuthStateNotifier(repository: repo);
      final success = await notifier.register(
        name: 'Player',
        email: 'used@example.com',
        password: 'secret123',
        acceptedTerms: true,
      );
      expect(success, isFalse);
      expect(notifier.state.status, AuthStatus.error);
      expect(notifier.state.message, 'Email занят');
    });

    test('google unavailable is a safe error state', () async {
      final notifier = AuthStateNotifier(repository: FakeAuthRepository());
      final success = await notifier.signInWithGoogle();
      expect(success, isFalse);
      expect(notifier.state.status, AuthStatus.error);
      expect(notifier.state.message, 'Google-вход требует настройки OAuth');
    });
  });

  testWidgets('login form shows Google and registration actions', (
    tester,
  ) async {
    final repo = FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          authStateProvider.overrideWith(
            (ref) => AuthStateNotifier(repository: repo),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: LoginForm())),
      ),
    );
    expect(find.byType(GhostButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });
}
