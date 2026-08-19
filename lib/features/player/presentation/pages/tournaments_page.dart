import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';

class TournamentsPage extends ConsumerWidget {
  const TournamentsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(tournamentProvider);
    return ref
        .watch(currentAuthUserProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (user) => Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Доступные турниры',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (user == null)
                  const Text('Войдите, чтобы зарегистрироваться')
                else
                  ...items.map((t) {
                    final registered = t.registeredPlayerIds.contains(user.id);
                    return Card(
                      color: const Color(0xff1D232C),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Buy-in ₽${t.buyIn.toStringAsFixed(0)} • Игроки ${t.currentPlayers}/${t.maxPlayers}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: registered
                                    ? null
                                    : () {
                                        final result = ref
                                            .read(tournamentProvider.notifier)
                                            .registerPlayer(t.id, user.id);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(result.message),
                                          ),
                                        );
                                      },
                                child: Text(
                                  registered
                                      ? 'Зарегистрирован'
                                      : 'Зарегистрироваться',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
  }
}
