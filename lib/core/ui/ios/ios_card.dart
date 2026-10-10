import 'package:flutter/material.dart';

class IosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const IosCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Container(
      decoration: BoxDecoration(
        color: isAndroid ? const Color(0xFF171B22) : const Color(0xFF0E1113),
        borderRadius: BorderRadius.circular(isAndroid ? 18 : 16),
        border: Border.all(
          color: Colors.white.withOpacity(isAndroid ? 0.08 : 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isAndroid ? 0.18 : 0.35),
            blurRadius: isAndroid ? 8 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
