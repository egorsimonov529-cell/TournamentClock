import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/providers/auth_state_provider.dart';
import '../features/auth/domain/models/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/player/presentation/pages/player_cabinet_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/login",

  redirect: (context, state) {
    // Проверяем что мы внутри ProviderScope
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authStateProvider);

    final isAuthenticated = authState.status == AuthStatus.authenticated;

    final isLoginRoute = state.matchedLocation == "/login";

    // Если уже на логине и не авторизован — остаемся на логине
    if (isLoginRoute && !isAuthenticated) {
      return null;
    }

    // Если на логине и уже авторизован — редиректим в зависимости от роли
    if (isLoginRoute && isAuthenticated) {
      final role = authState.userRole ?? "admin";
      if (role == "player") {
        return "/cabinet";
      }
      return "/dashboard";
    }

    // Если не на логине и не авторизован — редиректим на логин
    if (!isLoginRoute && !isAuthenticated) {
      return "/login";
    }

    // Все ок — остаемся на текущей странице
    return null;
  },

  routes: [
    GoRoute(
      path: "/login",
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: "/dashboard",
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: "/cabinet",
      builder: (context, state) => const PlayerCabinetPage(),
    ),
  ],
);