import 'package:flutter/material.dart';

import '../layout/login_desktop_layout.dart';
import '../layout/login_mobile_layout.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    if (width < 900) {
      return const LoginMobileLayout();
    }

    return const LoginDesktopLayout();
  }
}