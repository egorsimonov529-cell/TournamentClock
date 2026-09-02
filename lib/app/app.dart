import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../core/theme/app_theme.dart';
import '../features/dashboard/domain/admin_workspace_state.dart';
import 'router.dart';

class PokerClubApp extends ConsumerWidget {
  const PokerClubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(adminWorkspaceProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: workspace.clubName,
      theme: AppTheme.dark,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        final appChild = SafeArea(
          top: false,
          bottom: true,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );

        return ResponsiveBreakpoints.builder(
          child: appChild,
          breakpoints: const [
            Breakpoint(start: 0, end: 700, name: MOBILE),
            Breakpoint(start: 701, end: 1100, name: TABLET),
            Breakpoint(start: 1101, end: 2500, name: DESKTOP),
          ],
        );
      },
    );
  }
}
