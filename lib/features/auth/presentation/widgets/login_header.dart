import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'login_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [

        LoginLogo(),

        Gap(28),

        Text(
          "Poker Club ERM",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
          ),
        ),

        Gap(12),

        Text(
          "Войдите в систему управления клубом",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.5,
            fontSize: 15,
          ),
        ),

      ],
    );
  }
}