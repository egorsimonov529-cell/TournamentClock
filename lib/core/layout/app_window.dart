import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppWindow extends StatelessWidget {
  final Widget child;

  const AppWindow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _Background(),

          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -200,
          left: -150,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff00C875).withValues(alpha: .08),
            ),
          ),
        ),

        Positioned(
          right: -250,
          bottom: -200,
          child: Container(
            width: 700,
            height: 700,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff00C875).withValues(alpha: .05),
            ),
          ),
        ),

        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .03)
      ..strokeWidth = 1;

    const step = 40.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
