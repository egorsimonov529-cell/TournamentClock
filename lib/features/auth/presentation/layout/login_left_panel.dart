import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/club_logo.dart';
import '../../../dashboard/domain/admin_workspace_state.dart';

class LoginLeftPanel extends ConsumerWidget {
  const LoginLeftPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    final workspace = ref.watch(adminWorkspaceProvider);
    final clubName = workspace.clubName.trim().isNotEmpty ? workspace.clubName : 'Poker Club ERM';
    final logoUrl = workspace.logoUrl.isNotEmpty ? workspace.logoUrl : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Покерный зеленый фон
            Positioned.fill(
              child: CustomPaint(painter: _PokerBackgroundPainter(themeType)),
            ),
            // Контент
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: LayoutBuilder(
                builder: (context, innerConstraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: innerConstraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Логотип + название клуба
                            Row(
                              children: [
                                ClubLogo(
                                  logoUrl: logoUrl,
                                  size: 52,
                                  borderRadius: 14.0,
                                  borderColor: themeType.accent,
                                ),
                                const Gap(16),
                                Text(
                                  clubName,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                    color: Color(0xffF2F5F3),
                                  ),
                                ),
                              ],
                            ),

                            const Gap(32),

                            // Описание
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                "Современная система управления спортивным покерным клубом.\n\n"
                                "• Турниры\n"
                                "• Игроки\n"
                                "• Финансы\n"
                                "• Аналитика\n"
                                "• Лояльность\n"
                                "• Касса\n"
                                "• Сотрудники",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff8B9690),
                                  height: 1.7,
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Версия
                            const Text(
                              "Version 1.0",
                              style: TextStyle(
                                color: Color(0xff5A635E),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ========================================
// Покерный фон с мастями и картами
// ========================================
class _PokerBackgroundPainter extends CustomPainter {
  final AppThemeType themeType;

  const _PokerBackgroundPainter(this.themeType);

  @override
  void paint(Canvas canvas, Size size) {
    // Основной темный фон
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [themeType.primaryColor, themeType.gold, const Color(0xff0C0C0E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Текстура сукна
    final texturePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), texturePaint);

    // Рисуем разбросанные покерные масти
    final suits = ['♠', '♥', '♦', '♣'];
    final rand = Random(42);
    final paint = Paint();

    for (int i = 0; i < 20; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final suitSize = 18.0 + rand.nextDouble() * 35;
      final rotation = (rand.nextDouble() - 0.5) * 0.8;
      final opacity = 0.03 + rand.nextDouble() * 0.05;

      paint.style = PaintingStyle.fill;
      paint.color = rand.nextDouble() > 0.5
          ? const Color(0xffF5F0E8).withValues(alpha: opacity)
          : themeType.accent.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final textPainter = TextPainter(
        text: TextSpan(
          text: suits[rand.nextInt(suits.length)],
          style: TextStyle(fontSize: suitSize, color: paint.color),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-suitSize / 2, -suitSize / 2));

      canvas.restore();
    }

    // Рисуем контуры игровых фишек
    final chipColors = [
      const Color(0xffEF4444),
      const Color(0xff3B82F6),
      themeType.accent,
      themeType.borderColor,
      const Color(0xff8B5CF6),
    ];

    for (int i = 0; i < 6; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final chipRadius = 22.0 + rand.nextDouble() * 30;
      final opacity = 0.04 + rand.nextDouble() * 0.06;

      final chipPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = chipColors[i % chipColors.length].withValues(alpha: opacity);

      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = chipColors[(i + 1) % chipColors.length].withValues(
          alpha: opacity * 0.7,
        );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * 2 * pi);

      canvas.drawCircle(Offset.zero, chipRadius, chipPaint);
      canvas.drawCircle(Offset.zero, chipRadius * 0.65, innerPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
