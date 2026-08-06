import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final double width;

  const AppCard({
    super.key,
    required this.child,
    this.width = 520,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .45),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: const Color(0xff00C875).withValues(
                alpha: hover ? .10 : .05,
              ),
              blurRadius: hover ? 50 : 30,
              spreadRadius: hover ? 3 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              width: widget.width,
              padding: const EdgeInsets.all(42),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                color: const Color(0xff191D24).withValues(alpha: .72),
                border: Border.all(
                  color: hover
                      ? const Color(0xff00C875).withValues(alpha: .20)
                      : Colors.white.withValues(alpha: .06),
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}