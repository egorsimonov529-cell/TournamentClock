import 'package:flutter/material.dart';

import 'login_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LoginLogo(),
        SizedBox(height: 24),
        Text(
          "Вход в аккаунт",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xffF2F5F3),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Добро пожаловать обратно!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xff8B9690), fontSize: 15),
        ),
      ],
    );
  }
}
