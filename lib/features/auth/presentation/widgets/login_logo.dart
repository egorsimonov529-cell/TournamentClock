import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xff39B86A).withOpacity(.12),
        border: Border.all(
          color: const Color(0xff39B86A).withOpacity(.25),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.casino_rounded,
        color: Color(0xff39B86A),
        size: 42,
      ),
    );
  }
}
