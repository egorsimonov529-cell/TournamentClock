import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/providers/auth_state_provider.dart';
import '../features/auth/domain/models/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/registration_page.dart';
import '../features/auth/presentation/pages/recovery_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/player/presentation/pages/player_cabinet_page.dart';
import '../features/player/presentation/pages/tournament_detail_page.dart';
import '../features/player/presentation/pages/ios_login_page.dart';
import '../features/player/presentation/pages/ios_tournaments_page.dart';
import '../features/player/presentation/pages/transactions_page.dart';
import '../features/player/presentation/pages/loyalty_page.dart';
import '../features/player/presentation/pages/bonuses_page.dart';
import '../features/player/presentation/pages/achievements_page.dart';
import '../features/player/presentation/pages/notifications_page.dart';
import '../features/player/presentation/pages/support_page.dart';
import '../features/player/presentation/pages/about_club_page.dart';
import '../features/tournament_clock/presentation/screens/tournament_clock_fullscreen.dart';
import '../features/tables/presentation/screens/seating_screen.dart';

String? authRedirect(AuthState auth, String location) {
  if (auth.status == AuthStatus.initializing) return null;
  final authRoute =
      location == '/login' ||
      location == '/register' ||
      location == '/recovery';
  if (!auth.isAuthenticated) return authRoute ? null : '/login';
  final home = auth.userRole == 'admin' ? '/dashboard' : '/user';
  if (authRoute) return home;
  
  // Seating page is accessible by both admin and player
  final seatingRoute = location.startsWith('/tournament/') && location.endsWith('/seating');
  
  final adminRoute =
      location == '/dashboard' ||
      location == '/clock' ||
      (location.endsWith('/seating') && !seatingRoute);
  final playerRoute =
      location == '/user' ||
      location == '/cabinet' ||
      location == '/transactions' ||
      location == '/loyalty' ||
      location == '/bonuses' ||
      location == '/achievements' ||
      location == '/notifications' ||
      location == '/support' ||
      location == '/about' ||
      (location.startsWith('/tournament/') && !location.endsWith('/seating'));
  if (auth.userRole == 'admin' && playerRoute) return '/dashboard';
  if (auth.userRole == 'player' && adminRoute && !seatingRoute) return '/user';
  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.read(authStateProvider.notifier).checkInitialSession();

  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) =>
        authRedirect(ref.read(authStateProvider), state.matchedLocation),
    routes: [
      // Авторизация
      GoRoute(path: "/login", builder: (context, state) => const LoginPage()),
      // iPhone preview routes (dev)
      GoRoute(path: "/ios/login", builder: (context, state) => const IosLoginPage()),
      GoRoute(path: "/ios/tournaments", builder: (context, state) => const IosTournamentsPage()),
      GoRoute(
        path: "/register",
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: "/recovery",
        builder: (context, state) => const RecoveryPage(),
      ),

      // Админ панель
      GoRoute(
        path: "/dashboard",
        builder: (context, state) => const DashboardPage(),
      ),

      // Player App
      GoRoute(
        path: "/user",
        builder: (context, state) => const PlayerCabinetPage(),
      ),
      GoRoute(
        path: "/cabinet",
        builder: (context, state) => const PlayerCabinetPage(),
      ),
      GoRoute(
        path: "/tournament/:id/seating",
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SeatingScreen(tournamentId: id);
        },
      ),
      GoRoute(
        path: "/tournament/:id",
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TournamentDetailPage(tournamentId: id);
        },
      ),
      GoRoute(
        path: "/transactions",
        builder: (context, state) => const TransactionsPage(),
      ),
      GoRoute(
        path: "/loyalty",
        builder: (context, state) => const LoyaltyPage(),
      ),
      GoRoute(
        path: "/bonuses",
        builder: (context, state) => const BonusesPage(),
      ),
      GoRoute(
        path: "/achievements",
        builder: (context, state) => const AchievementsPage(),
      ),
      GoRoute(
        path: "/notifications",
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: "/support",
        builder: (context, state) => const SupportPage(),
      ),
      GoRoute(
        path: "/about",
        builder: (context, state) => const AboutClubPage(),
      ),

      // Tournament Clock
      GoRoute(
        path: "/clock",
        builder: (context, state) => const TournamentClockFullscreenScreen(),
      ),
    ],
  );
  ref.listen(authStateProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
