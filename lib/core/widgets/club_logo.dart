import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

/// Виджет логотипа клуба.
/// Поддерживает:
/// - URL (http/https) — загружается через Image.network
/// - Путь к asset (assets/...) — загружается через Image.asset
/// - Пустое значение — показывает иконку-заглушку
class ClubLogo extends StatelessWidget {
  const ClubLogo({
    super.key,
    this.logoUrl,
    this.size = 80,
    this.borderRadius = 20.0,
    this.borderWidth = 1.5,
    this.borderColor,
  });

  final String? logoUrl;
  final double size;
  final double borderRadius;
  final double borderWidth;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppColors.accent;
    final fallback = _FallbackLogo(
      size: size,
      borderRadius: borderRadius,
      color: color,
    );

    if (logoUrl == null || logoUrl!.trim().isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: color.withValues(alpha: 0.25), width: borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          child: SvgPicture.asset(
            'assets/logos/club_logo.svg',
            fit: BoxFit.cover,
            placeholderBuilder: (_) => fallback,
          ),
        ),
      );
    }

    final normalized = logoUrl!.trim();

    // URL (загруженный логотип с бэкенда)
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: color.withValues(alpha: 0.25), width: borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          child: Image.network(
            normalized,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return fallback;
            },
          ),
        ),
      );
    }

    // Asset path (статичный файл)
    if (normalized.startsWith('assets/')) {
      final isSvg = normalized.toLowerCase().endsWith('.svg');
      if (isSvg) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: color.withValues(alpha: 0.25), width: borderWidth),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
            child: SvgPicture.asset(
              normalized,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => fallback,
            ),
          ),
        );
      }
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: color.withValues(alpha: 0.25), width: borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          child: Image.asset(
            normalized,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          ),
        ),
      );
    }

    // Неизвестный формат — показываем fallback
    return fallback;
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({
    required this.size,
    required this.borderRadius,
    required this.color,
  });

  final double size;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: color.withValues(alpha: .12),
        border: Border.all(color: color.withValues(alpha: .25), width: 1.5),
      ),
      child: Icon(
        Icons.casino_rounded,
        color: color,
        size: size * 0.52,
      ),
    );
  }
}
