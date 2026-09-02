import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Миксин для анимации волны на кнопках
mixin RippleButtonMixin on StatefulWidget {
  /// Создаёт стиль ElevatedButton с анимацией волны
  static ButtonStyle rippleStyle({Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.accent,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      elevation: 0,
      animationDuration: const Duration(milliseconds: 600),
    );
  }
}

/// Основная кнопка с фирменным цветом и анимацией волны
class PrimaryButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final bool disabled;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.disabled = false,
  });

  @override
  ConsumerState<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends ConsumerState<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    if (mounted) {
      setState(() => _isHovering = isHovering);
    }
    if (isHovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeType = ref.watch(themeProvider);
    final effectiveOnPressed = (widget.onPressed == null || widget.disabled)
        ? null
        : widget.onPressed;

    _colorAnimation = ColorTween(
      begin: themeType.accent,
      end: themeType.goldLight,
    ).animate(_controller);

    if (widget.outlined) {
      return MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: effectiveOnPressed,
              label: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _isHovering
                      ? themeType.goldLight
                      : themeType.accent,
                ),
              ),
              icon: widget.loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          themeType.accent,
                        ),
                      ),
                    )
                  : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: _isHovering
                    ? themeType.goldLight
                    : themeType.accent,
                side: BorderSide(
                  color: _isHovering
                      ? themeType.goldLight
                      : themeType.accent,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.disabled
                  ? AppColors.textMuted
                  : widget.loading
                  ? themeType.primaryLight
                  : _colorAnimation.value ?? themeType.accent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              elevation: _isHovering ? 8 : 0,
            ),
            child: widget.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Кнопка с фирменным акцентом и анимацией волны
class GoldButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const GoldButton({super.key, required this.label, this.onPressed});

  @override
  ConsumerState<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends ConsumerState<GoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    if (mounted) {
      setState(() => _isHovering = isHovering);
    }
    if (isHovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeType = ref.watch(themeProvider);

    _colorAnimation = ColorTween(
      begin: themeType.gold,
      end: themeType.goldLight,
    ).animate(_controller);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorAnimation.value ?? themeType.gold,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              elevation: _isHovering ? 8 : 0,
            ),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.background,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Вторичная кнопка (ghost)
class GhostButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;

  const GhostButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: themeType.borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          backgroundColor: AppColors.card,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

/// Маленькая кнопка
class SmallButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  const SmallButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: filled
            ? BoxDecoration(
                color: themeType.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: themeType.borderColor, width: 1),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: filled ? themeType.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
