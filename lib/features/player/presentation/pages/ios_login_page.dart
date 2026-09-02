import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../auth/presentation/widgets/login_form.dart';

class IosLoginPage extends StatelessWidget {
  const IosLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Вход')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const LoginForm(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
