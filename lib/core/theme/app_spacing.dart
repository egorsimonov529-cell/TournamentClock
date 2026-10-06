import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 56;

  // Page padding
  static const double pageHorizontal = 20;
  static const double pageVertical = 16;

  // Card padding
  static const double card = 20;
  static const double cardSm = 16;
  static const double cardLg = 24;

  // Responsive helpers
  static double responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    return 24.0;
  }

  static double responsiveCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    return 20.0;
  }

  static double responsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.85;
    if (width < 600) return baseSize * 0.92;
    return baseSize;
  }
}
