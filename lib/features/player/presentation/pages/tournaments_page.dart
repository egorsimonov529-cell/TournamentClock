import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../../core/ui/ios/ios_button.dart';

class TournamentsPage extends ConsumerWidget {
  const TournamentsPage({super.key});

  Future<void> _registerAndGoToSeating(
    BuildContext context,
    WidgetRef ref,
    String tournamentId,
    String playerId,
  ) async {
    try {
      // Вызываем API регистрации
      await ApiService().post(
        '/tournaments/$tournamentId/players',
        data: {'player_id': playerId},
      );

      // Обновляем локальный стейт турниров и ждём завершения
      if (context.mounted) {
        await ref.read(tournamentProvider.notifier).load();
      }

      // Небольшая задержка для обновления стейта
      await Future.delayed(const Duration(milliseconds: 300));

      // Переходим к рассадке
      if (context.mounted) {
        context.push('/tournament/$tournamentId/seating');
      }
    } catch (e) {
      print('Ошибка регистрации: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка регистрации: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(tournamentProvider);

    return ref.watch(currentAuthUserProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (user) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Доступные турниры',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            if (user == null)
              const Text('Войдите, чтобы зарегистрироваться')
            else
              ...items.map((t) {
                final registered = t.registeredPlayerIds.contains(user.id);
                return IosCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Взнос ₽${t.buyIn.toStringAsFixed(0)} • Игроки ${t.currentPlayers}/${t.maxPlayers}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: IosButton(
                            filled: !registered,
                            label: registered ? 'Перейти к рассадке' : 'Зарегистрироваться',
                            onPressed: registered
                                ? () {
                                    context.push('/tournament/${t.id}/seating');
                                  }
                                : () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Зарегистрироваться'),
                                        content: Text('Подтвердить регистрацию на "${t.name}"?\n\nПосле регистрации вы сможете выбрать место за столом.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
                                          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Подтвердить')),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await _registerAndGoToSeating(context, ref, t.id, user.id);
                                    }
                                  },
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
