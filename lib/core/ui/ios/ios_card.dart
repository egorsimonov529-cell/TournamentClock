import 'package:flutter/material.dart';

class IosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const IosCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1113),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: Offset(0,6))],
      ),
      padding: padding,
      child: child,
    );
  }
}
