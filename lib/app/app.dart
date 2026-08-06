import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class PokerClubApp extends StatelessWidget {
  const PokerClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'Poker Club ERM',

      theme: AppTheme.dark,

      routerConfig: appRouter,

      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
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