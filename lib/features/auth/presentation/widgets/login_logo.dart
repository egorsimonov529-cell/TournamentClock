import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';

class LoginLogo extends ConsumerWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: themeType.accent.withValues(alpha: .12),
        border: Border.all(
          color: themeType.accent.withValues(alpha: .25),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.casino_rounded,
        color: themeType.accent,
        size: 42,
      ),
    );
  }
}
