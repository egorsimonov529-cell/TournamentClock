import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xff00C875).withValues(alpha: .12),
        border: Border.all(
          color: const Color(0xff00C875).withValues(alpha: .25),
        ),
      ),
      child: const Icon(
        Icons.casino_rounded,
        color: Color(0xff00C875),
        size: 46,
      ),
    );
  }
}