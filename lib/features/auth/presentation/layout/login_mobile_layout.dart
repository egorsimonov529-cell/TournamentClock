import 'package:flutter/material.dart';

import '../../../../core/layout/app_window.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

class LoginMobileLayout extends StatelessWidget {
  const LoginMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWindow(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            child: AppCard(
              child: const Column(
                children: [LoginHeader(), SizedBox(height: 32), LoginForm()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
