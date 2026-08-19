import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/player_provider.dart';
import '../layout/player_cabinet_layout.dart';

class PlayerCabinetPage extends ConsumerWidget {
  const PlayerCabinetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProfileProvider);

    return playerAsync.when(
      data: (player) {
        return PlayerCabinetLayout(player: player);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              "Ошибка загрузки профиля",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
