import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IosButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final bool filled;

  const IosButton({
    super.key,
    required this.label,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    if (isAndroid) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: padding,
          backgroundColor: filled ? const Color(0xFF0A84FF) : Colors.transparent,
          foregroundColor: filled ? Colors.white : const Color(0xFF0A84FF),
          side: filled ? null : const BorderSide(color: Color(0xFF0A84FF), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return CupertinoButton(
      onPressed: onPressed,
      padding: padding,
      color: filled ? CupertinoColors.activeBlue : null,
      borderRadius: BorderRadius.circular(12),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : CupertinoColors.activeBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
