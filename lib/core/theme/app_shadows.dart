import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .18),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: const Color(0xff00C875).withValues(alpha: .25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
