import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

class AppButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  const AppButton({
    super.key,
    required this.title,
    this.onPressed,
    this.icon,
    this.loading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: LinearGradient(
              colors: hover
                  ? const [
                      Color(0xff14E38A),
                      Color(0xff00C875),
                    ]
                  : const [
                      Color(0xff00C875),
                      Color(0xff00B368),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff00C875).withValues(
                  alpha: hover ? .45 : .25,
                ),
                blurRadius: hover ? 30 : 18,
                spreadRadius: hover ? 2 : 0,
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon ?? Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}