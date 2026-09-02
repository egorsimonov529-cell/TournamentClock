import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IosButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final bool filled;

  const IosButton({super.key, required this.label, this.onPressed, this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16), this.filled = true});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: padding,
      color: filled ? CupertinoColors.activeBlue : null,
      borderRadius: BorderRadius.circular(12),
      child: Text(label, style: TextStyle(color: filled ? Colors.white : CupertinoColors.activeBlue, fontWeight: FontWeight.w600)),
    );
  }
}
