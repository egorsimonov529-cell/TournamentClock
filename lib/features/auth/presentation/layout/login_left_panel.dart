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
              child: CustomPaint(painter: _PokerBackgroundPainter()),
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
                            // Логотип
                            Row(
                              children: [
                                Icon(
                                  Icons.casino_rounded,
                                  color: const Color(0xff39B86A),
                                  size: 44,
                                ),
                                const Gap(16),
                                const Text(
                                  "Poker Club\nERM",
                                  style: TextStyle(
                                    fontSize: 38,
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
  @override
  void paint(Canvas canvas, Size size) {
    // Основной темный фон
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xff176B3A), Color(0xff0F3D24), Color(0xff0B100E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Текстура сукна
    final texturePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.1),
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
          ? const Color(0xffF2F5F3).withValues(alpha: opacity)
          : const Color(0xff39B86A).withValues(alpha: opacity);

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
      const Color(0xffC9A84E),
      const Color(0xff39B86A),
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
