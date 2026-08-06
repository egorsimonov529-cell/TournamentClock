import 'package:flutter/material.dart';

import '../../../../core/layout/app_window.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';
import 'login_left_panel.dart';

class LoginDesktopLayout extends StatelessWidget {
  const LoginDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWindow(
      child: Row(
        children: [
          const Expanded(
            flex: 6,
            child: LoginLeftPanel(),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
  horizontal: 80,
  vertical: 40,
),
                child: AppCard(
                  width: 540,
                  child: const Column(
                    children: [
                      LoginHeader(),
                      SizedBox(height: 40),
                      LoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}