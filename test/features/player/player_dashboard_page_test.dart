import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/features/player/presentation/pages/player_dashboard_page.dart';
import 'package:tournament_clock/features/player/presentation/pages/profile_settings_page.dart';

void main() {
  testWidgets('profile CTA opens profile settings', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PlayerDashboardPage())));
    await tester.tap(find.text('Мой профиль'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSettingsPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ProfileSettingsPage),
        matching: find.text('Настройки профиля'),
      ),
      findsWidgets,
    );
  });
}
