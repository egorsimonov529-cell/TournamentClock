import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../../../tournament/domain/models/tournament_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
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

  void _showTournamentDetails(BuildContext context, Tournament t) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1D232C),
        title: Text(
          t.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Описание
              if (t.description.isNotEmpty) ...[
                const Text(
                  'Описание',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Формат
              const Text(
                'Формат',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.format,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Игроки
              const Text(
                'Зарегистрировано',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${t.currentPlayers} из ${t.maxPlayers}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (t.isFull) ...[
                const SizedBox(height: 6),
                const Text(
                  'Мест нет',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Бай-ин
              const Text(
                'Взнос',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₽${t.buyIn.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(tournamentProvider);
    final isCompact = MediaQuery.sizeOf(context).width < 420;

    return ref.watch(currentAuthUserProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (user) => Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 20),
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
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = items[index];
                    final registered = t.registeredPlayerIds.contains(user.id);
                    final confirmed = t.isPlayerConfirmed(user.id);
                    final eliminated = t.isPlayerEliminated(user.id);
                    final guestStatus = eliminated
                        ? 'Выбыл'
                        : (confirmed ? 'Подтверждён' : (registered ? 'Ожидает подтверждения' : null));

                    return IosCard(
                      child: Padding(
                        padding: EdgeInsets.all(isCompact ? 12 : 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Взнос ₽${t.buyIn.toStringAsFixed(0)} • Игроки ${t.currentPlayers}/${t.maxPlayers}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (guestStatus != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: eliminated
                                      ? Colors.redAccent.withValues(alpha: 0.12)
                                      : (confirmed
                                          ? AppColors.primary.withValues(alpha: 0.12)
                                          : AppColors.warning.withValues(alpha: 0.12)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: eliminated
                                        ? Colors.redAccent.withValues(alpha: 0.3)
                                        : (confirmed
                                            ? AppColors.primary.withValues(alpha: 0.3)
                                            : AppColors.warning.withValues(alpha: 0.3)),
                                  ),
                                ),
                                child: Text(
                                  guestStatus,
                                  style: TextStyle(
                                    color: eliminated
                                        ? Colors.redAccent
                                        : (confirmed
                                            ? AppColors.primary
                                            : AppColors.warning),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Кнопка "Подробнее"
                            InkWell(
                              onTap: () => _showTournamentDetails(context, t),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Подробнее',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (registered && !confirmed)
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        final removed = await ref.read(tournamentProvider.notifier).removePlayer(
                                          t.id,
                                          user.id,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                removed
                                                    ? 'Регистрация отменена'
                                                    : 'Отмена регистрации недоступна',
                                              ),
                                              backgroundColor: removed ? null : Colors.orange,
                                            ),
                                          );
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white24),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Отменить регистрацию'),
                                    ),
                                  ),
                                ],
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: IosButton(
                                  filled: !registered,
                                  label: registered
                                      ? 'Подтверждён'
                                      : 'Зарегистрироваться',
                                  onPressed: registered
                                      ? () {
                                          if (confirmed) {
                                            context.push('/tournament/${t.id}/seating');
                                            return;
                                          }
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Регистрация ожидает подтверждения администратором'),
                                            ),
                                          );
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
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
