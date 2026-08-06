import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LoginLeftPanel extends StatelessWidget {
  const LoginLeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Покерный зеленый фон
            Positioned.fill(
              child: CustomPaint(
                painter: _PokerBackgroundPainter(),
              ),
            ),
            // Контент
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 60,
                vertical: 40,
              ),
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
                            // Логотип
                            Row(
                              children: [
                                Icon(
                                  Icons.casino_rounded,
                                  color: const Color(0xff00C875),
                                  size: 48,
                                ),
                                const Gap(16),
                                Text(
                                  "Poker Club\nERM",
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
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
                                "• CRM\n"
                                "• Финансы\n"
                                "• Аналитика\n"
                                "• Рейтинг\n"
                                "• Касса\n"
                                "• Администраторы",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  height: 1.7,
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Версия
                            Text(
                              "Version 0.1 MVP",
                              style: TextStyle(
                                color: Colors.white38,
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
  @override
  void paint(Canvas canvas, Size size) {
    // Основной зеленый фон (покерный стол)
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xff1A472A),
          const Color(0xff143D24),
          const Color(0xff0F3319),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Текстура сукна
    final texturePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), texturePaint);

    // Рисуем разбросанные покерные масти
    final suits = ['♠', '♥', '♦', '♣'];
    final rand = Random(42);
    final paint = Paint();

    for (int i = 0; i < 25; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final suitSize = 20.0 + rand.nextDouble() * 40;
      final rotation = (rand.nextDouble() - 0.5) * 0.8;
      final opacity = 0.03 + rand.nextDouble() * 0.06;

      paint.style = PaintingStyle.fill;
      paint.color = rand.nextDouble() > 0.5
          ? Colors.white.withValues(alpha: opacity)
          : const Color(0xff00C875).withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final textPainter = TextPainter(
        text: TextSpan(
          text: suits[rand.nextInt(suits.length)],
          style: TextStyle(
            fontSize: suitSize,
            color: paint.color,
          ),
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
      const Color(0xffF59E0B),
      const Color(0xff10B981),
      const Color(0xff8B5CF6),
    ];

    for (int i = 0; i < 8; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final chipRadius = 25.0 + rand.nextDouble() * 35;
      final opacity = 0.06 + rand.nextDouble() * 0.08;

      final chipPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = chipColors[i % chipColors.length].withValues(alpha: opacity);

      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = chipColors[(i + 1) % chipColors.length].withValues(alpha: opacity * 0.7);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * 2 * pi);

      canvas.drawCircle(Offset.zero, chipRadius, chipPaint);
      canvas.drawCircle(Offset.zero, chipRadius * 0.65, innerPaint);

      // Бороздки на фишке
      for (int j = 0; j < 8; j++) {
        final angle = j * pi / 4;
        canvas.drawLine(
          Offset(cos(angle) * chipRadius * 0.8, sin(angle) * chipRadius * 0.8),
          Offset(cos(angle) * chipRadius, sin(angle) * chipRadius),
          innerPaint,
        );
      }

      canvas.restore();
    }

    // Параллельная линия в стиле покерного сукна
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xff00C875).withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.3, size.width, 1.5));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.3, size.width, 1.5),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
