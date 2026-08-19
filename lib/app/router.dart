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
import '../features/player/presentation/pages/transactions_page.dart';
import '../features/player/presentation/pages/loyalty_page.dart';
import '../features/player/presentation/pages/bonuses_page.dart';
import '../features/player/presentation/pages/achievements_page.dart';
import '../features/player/presentation/pages/notifications_page.dart';
import '../features/player/presentation/pages/support_page.dart';
import '../features/player/presentation/pages/about_club_page.dart';
import '../features/tournament_clock/presentation/screens/tournament_clock_fullscreen.dart';
import '../features/tables/presentation/screens/seating_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/login",

  redirect: (context, state) {
    // Проверяем что мы внутри ProviderScope
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authStateProvider);

    final isAuthenticated = authState.status == AuthStatus.authenticated;

    final isAuthRoute = [
      "/login",
      "/register",
      "/recovery",
    ].contains(state.matchedLocation);

    // Если уже на экране авторизации и не авторизован — остаемся
    if (isAuthRoute && !isAuthenticated) {
      return null;
    }

    // Если на экране авторизации и уже авторизован — редиректим
    if (isAuthRoute && isAuthenticated) {
      final role = authState.userRole ?? "admin";
      if (role == "player") {
        return "/cabinet";
      }
      return "/dashboard";
    }

    // Если не на экране авторизации и не авторизован — редиректим на логин
    if (!isAuthRoute && !isAuthenticated) {
      return "/login";
    }

    // Все ок — остаемся на текущей странице
    return null;
  },

  routes: [
    // Авторизация
    GoRoute(path: "/login", builder: (context, state) => const LoginPage()),
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
    GoRoute(path: "/loyalty", builder: (context, state) => const LoyaltyPage()),
    GoRoute(path: "/bonuses", builder: (context, state) => const BonusesPage()),
    GoRoute(
      path: "/achievements",
      builder: (context, state) => const AchievementsPage(),
    ),
    GoRoute(
      path: "/notifications",
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(path: "/support", builder: (context, state) => const SupportPage()),
    GoRoute(path: "/about", builder: (context, state) => const AboutClubPage()),

    // Tournament Clock
    GoRoute(
      path: "/clock",
      builder: (context, state) => const TournamentClockFullscreenScreen(),
    ),
  ],
);
