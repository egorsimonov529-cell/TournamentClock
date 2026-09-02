import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../../core/ui/ios/ios_button.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tournament/domain/models/tournament_model.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';

class MyTournamentsPage extends ConsumerWidget {
  const MyTournamentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentProvider);

    return ref
        .watch(currentAuthUserProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (user) {
            final registered = user == null
                ? const <Tournament>[]
                : tournaments
                      .where(
                        (tournament) =>
                            tournament.registeredPlayerIds.contains(user.id),
                      )
                      .toList();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Мои турниры',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Зарегистрированные турниры',
                    style: TextStyle(color: Colors.white.withValues(alpha: .6)),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: registered.isEmpty
                        ? const _EmptyTournaments()
                        : ListView.separated(
                            itemCount: registered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final tournament = registered[index];
                              return IosCard(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.emoji_events_outlined,
                                  ),
                                  title: Text(tournament.name),
                                  subtitle: Text(
                                    '${tournament.format} • '
                                    '${tournament.registeredPlayerIds.length}/'
                                    '${tournament.maxPlayers}',
                                  ),
                                  trailing: IosButton(
                                    label: 'Отменить',
                                    filled: false,
                                    onPressed: () {
                                      ref
                                          .read(tournamentProvider.notifier)
                                          .removePlayer(
                                            tournament.id,
                                            user!.id,
                                          );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Регистрация отменена'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
  }
}

class _EmptyTournaments extends StatelessWidget {
  const _EmptyTournaments();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              color: AppColors.accent,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Нет зарегистрированных турниров',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Выберите турнир в разделе «Турниры»',
              style: TextStyle(color: Colors.white.withValues(alpha: .6)),
            ),
          ],
        ),
      ),
    );
  }
}
