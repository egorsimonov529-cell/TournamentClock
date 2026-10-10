import 'package:flutter/material.dart';

import '../../../../core/layout/app_window.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

class LoginMobileLayout extends StatelessWidget {
  const LoginMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 500;
    final horizontalPadding = isPhone ? 16.0 : 24.0;
    final cardWidth = isPhone ? null : 420.0;

    return Scaffold(
      backgroundColor: const Color(0xff0F1117),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isPhone ? 24.0 : 32.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: cardWidth ?? double.infinity,
              ),
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [LoginHeader(), SizedBox(height: 32), LoginForm()],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
