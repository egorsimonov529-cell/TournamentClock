import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../auth/presentation/widgets/login_form.dart';

class IosLoginPage extends StatelessWidget {
  const IosLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 400;
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Вход')),
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12.0 : 16.0,
              vertical: 24.0,
            ),
            child: Column(
              children: [
                const LoginForm(),
                const Spacer(),
                SizedBox(height: isCompact ? 40.0 : 60.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
