import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TimerCircularProgress extends StatefulWidget {
  final String time;
  final double progress;
  final bool isPaused;
  final bool isBreak;
  final String? logoUrl;

  const TimerCircularProgress({
    super.key,
    required this.time,
    required this.progress,
    this.isPaused = false,
    this.isBreak = false,
    this.logoUrl,
  });

  @override
  State<TimerCircularProgress> createState() => _TimerCircularProgressState();
}

class _TimerCircularProgressState extends State<TimerCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _progressAnimation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(TimerCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(_controller);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diameter = (size.width < 700)
        ? size.width * 0.75
        : 380.0;

    final color = widget.isBreak
        ? AppColors.warning
        : widget.isPaused
            ? Colors.grey
            : AppColors.gold;

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(diameter, diameter),
          painter: _CircularProgressPainter(
            progress: _progressAnimation.value,
            color: color,
            diameter: diameter,
          ),
        ),
        if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty)
          Positioned.fill(
            child: Center(
              child: Image.network(
                widget.logoUrl!,
                width: diameter * 0.25,
                height: diameter * 0.25,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              ),
            ),
          ),
        Positioned.fill(
          child: Center(
            child: Text(
              widget.time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 90,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                letterSpacing: 4,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double diameter;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.diameter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = diameter / 2;

    final bgPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 4, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = progress * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final dotCount = 60;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * pi - pi / 2;
      final dotRadius = radius - 16;
      final dotX = center.dx + dotRadius * cos(angle);
      final dotY = center.dy + dotRadius * sin(angle);
      if (i / dotCount <= progress) {
        canvas.drawCircle(Offset(dotX, dotY), 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
