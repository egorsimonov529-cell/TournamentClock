import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/window_manager_service.dart';
import '../theme/app_colors.dart';

class DesktopAppShell extends StatelessWidget {
  const DesktopAppShell({
    super.key,
    required this.child,
    required this.clubName,
    required this.clubShortName,
    required this.logoAssetPath,
  });

  final Widget child;
  final String clubName;
  final String clubShortName;
  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final displayName = clubName.trim().isNotEmpty ? clubName : 'Poker Club';
    final logoText = clubShortName.trim().isNotEmpty ? clubShortName : 'PC';

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07090B), Color(0xFF111417), Color(0xFF090C10)],
        ),
      ),
      child: ClipRRect(
        child: Column(
          children: [
            Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF121317), Color(0xFF161A1E), Color(0xFF0F1216)],
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.4), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  _LogoBadge(
                    logoAssetPath: logoAssetPath,
                    logoText: logoText,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF7F0D8),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.45,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _WindowControl(
                        icon: Icons.remove_rounded,
                        onPressed: () => WindowManagerService.minimizeWindow(),
                      ),
                      const SizedBox(width: 10),
                      _WindowControl(
                        icon: Icons.close_rounded,
                        onPressed: () => WindowManagerService.closeApplication(),
                        accent: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D1115), Color(0xFF13191E)],
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({
    required this.logoAssetPath,
    required this.logoText,
  });

  final String logoAssetPath;
  final String logoText;

  @override
  Widget build(BuildContext context) {
    final normalized = logoAssetPath.trim();
    final fallback = Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7C76B), Color(0xFFB9882E)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1D48B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE9C96A).withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        logoText.length > 2 ? logoText.substring(0, 2).toUpperCase() : logoText.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF17120A),
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );

    if (normalized.isEmpty) return fallback;

    final lower = normalized.toLowerCase();
    if (lower.endsWith('.svg')) {
      return Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5C46A), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE5C46A).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SvgPicture.asset(
            normalized,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => fallback,
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5C46A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5C46A).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.asset(
          normalized,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

class _WindowControl extends StatelessWidget {
  const _WindowControl({
    required this.icon,
    required this.onPressed,
    this.accent = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final background = accent
        ? const LinearGradient(
            colors: [Color(0xFF1D1712), Color(0xFF2B2119)],
          )
        : const LinearGradient(
            colors: [Color(0xFF161A1E), Color(0xFF1B2026)],
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accent ? const Color(0xFFDAA94E) : const Color(0xFF2F3843),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent
                    ? const Color(0xFFDAA94E).withValues(alpha: 0.2)
                    : const Color(0xFF3A4A5D).withValues(alpha: 0.14),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: accent ? const Color(0xFFF0D18A) : const Color(0xFFEAEAF0),
            size: 18,
          ),
        ),
      ),
    );
  }
}
