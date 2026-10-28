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

final selectedTournamentTabProvider = StateProvider<int>((ref) => 0);

class TournamentsPage extends ConsumerWidget {
  const TournamentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTournamentTabProvider);
    final allItems = ref.watch(tournamentProvider);
    final activeTournaments = allItems.where((t) => t.status != 'completed' && t.status != 'cancelled').toList();
    final completedTournaments = allItems.where((t) => t.status == 'completed' || t.status == 'cancelled').toList();
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
              'Турниры',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _TournamentTab(
                    label: 'Доступные',
                    selected: selectedTab == 0,
                    onTap: () => ref.read(selectedTournamentTabProvider.notifier).state = 0,
                    count: activeTournaments.length,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TournamentTab(
                    label: 'Завершенные',
                    selected: selectedTab == 1,
                    onTap: () => ref.read(selectedTournamentTabProvider.notifier).state = 1,
                    count: completedTournaments.length,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (user == null)
              const Text('Войдите, чтобы зарегистрироваться')
            else
              Expanded(
                child: ListView.separated(
                  itemCount: selectedTab == 0 ? activeTournaments.length : completedTournaments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tournaments = selectedTab == 0 ? activeTournaments : completedTournaments;
                    final t = tournaments[index];
                    final registered = t.registeredPlayerIds.contains(user.id);
                    final confirmed = t.isPlayerConfirmed(user.id);
                    final eliminated = t.isPlayerEliminated(user.id);
                    final guestStatus = selectedTab == 0
                        ? eliminated
                            ? 'Выбыл'
                            : (confirmed ? 'Подтверждён' : (registered ? 'Ожидает подтверждения' : null))
                        : (registered && confirmed ? 'Участвовал' : null);

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
                              'Взнос ₽${t.buyIn.toStringAsFixed(0)} • Игроки ${t.currentPlayers}/${t.maxPlayers} • ${_formatDate(t.startDate)}',
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
                            if (selectedTab == 0) ...[
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
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => context.push('/tournament/${t.id}/seating'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.accent,
                                          side: const BorderSide(color: AppColors.accent),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Рассадка'),
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
                                        : () {
                                            showDialog<bool>(
                                              context: context,
                                              builder: (dialogContext) => AlertDialog(
                                                title: const Text('Зарегистрироваться'),
                                                content: Text('Подтвердить регистрацию на "${t.name}"?\n\nПосле регистрации вы сможете выбрать место за столом.'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
                                                  FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Подтвердить')),
                                                ],
                                              ),
                                            ).then((confirmed) {
                                              if (confirmed == true) {
                                                _registerAndGoToSeating(context, ref, t.id, user.id);
                                              }
                                            });
                                          },
                                  ),
                                ),
                            ] else ...[
                              InkWell(
                                onTap: () => _showTournamentDetails(context, t),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.visibility,
                                        size: 16,
                                        color: AppColors.accent,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Посмотреть результаты',
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
                            ],
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

  Future<void> _registerAndGoToSeating(
    BuildContext context,
    WidgetRef ref,
    String tournamentId,
    String playerId,
  ) async {
    try {
      await ApiService().post(
        '/tournaments/$tournamentId/players',
        data: {'player_id': playerId},
      );

      if (context.mounted) {
        await ref.read(tournamentProvider.notifier).load();
      }

      await Future.delayed(const Duration(milliseconds: 300));

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

  String _formatDate(DateTime date) {
    final days = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
    final months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final dayName = days[date.weekday % 7];
    final day = date.day;
    final month = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$dayName, $day $month в $hour:$minute';
  }
}

class _TournamentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int count;

  const _TournamentTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.background,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
