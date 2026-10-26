import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IosInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label; // alias for placeholder for compatibility
  final bool obscure;
  final int? maxLines;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  const IosInput({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.obscure = false,
    this.maxLines,
    this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder ?? label,
      obscureText: obscure,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      prefix: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(prefixIcon, size: 18, color: Colors.white54),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111418),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
