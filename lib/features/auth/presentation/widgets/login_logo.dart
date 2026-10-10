import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/club_logo.dart';
import '../../../dashboard/domain/admin_workspace_state.dart';

class LoginLogo extends ConsumerWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    final logoUrl = ref.watch(adminWorkspaceProvider).logoUrl;

    return ClubLogo(
      logoUrl: logoUrl.isNotEmpty ? logoUrl : null,
      size: 80,
      borderRadius: 20.0,
      borderColor: themeType.accent,
    );
  }
}
