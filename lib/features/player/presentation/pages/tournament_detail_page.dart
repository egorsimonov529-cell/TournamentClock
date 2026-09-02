import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../../core/ui/ios/ios_button.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../widgets/screen_widgets.dart';

class TournamentDetailPage extends ConsumerStatefulWidget {
  final String tournamentId;

  const TournamentDetailPage({super.key, required this.tournamentId});

  static const _tabs = ['О турнире', 'Структура', 'Игроки'];
  static const _content = [
    'Deepstack турнир с замедленной структурой. Поздняя регистрация до 22:00. Re-entry разрешен. Add-on после 2-го уровня.',
    'Уровни по 15 минут. Стартовые блайнды 25/50. Перерыв после каждого четвёртого уровня.',
    'Зарегистрировано 48 игроков из 100. Список участников обновляется после подтверждения регистрации.',
  ];

  Future<void> _registerAndGoToSeating(
    BuildContext context,
    WidgetRef ref,
    String tournamentId,
  ) async {
    // Получаем текущего пользователя
    final authState = ref.read(currentAuthUserProvider);
    
    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (user) async {
        if (user == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Необходимо авторизоваться')),
            );
          }
          return;
        }

        // Подтверждение регистрации
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Зарегистрироваться'),
            content: const Text(
              'Подтвердить регистрацию и списание бай-ина 2 000 ₽?\n\nПосле регистрации вы сможете выбрать место за столом.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Подтвердить'),
              ),
            ],
          ),
        );

        if (confirmed != true || !context.mounted) return;

        // Показываем индикатор загрузки
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        try {
          // Вызываем API регистрации
          await ApiService().post(
            '/tournaments/$tournamentId/players',
            data: {'player_id': user.id},
          );

          // Закрываем индикатор загрузки
          if (context.mounted) {
            Navigator.pop(context); // закрываем progressDialog
          }

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
          // Закрываем индикатор загрузки
          if (context.mounted) {
            Navigator.pop(context); // закрываем progressDialog
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка регистрации: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  @override
  ConsumerState<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends ConsumerState<TournamentDetailPage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentProvider);
    final tournament = tournaments
      .where((t) => t.id == widget.tournamentId)
      .firstOrNull;
    
    final authState = ref.watch(currentAuthUserProvider);
    bool isRegistered = false;
    
    authState.whenData((user) {
      if (tournament != null && user != null) {
        isRegistered = tournament.registeredPlayerIds.contains(user.id);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: ScreenTitle(title: 'Night Deepstack'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '15 августа 2026',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Начало: 21:00',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  IosCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.card),
                      child: Column(
                        children: const [
                          Text(
                            'Бай-ин',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '2 000 ₽',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Информация')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: IosCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _infoRow('Призовой фонд', '150 000 ₽', Icons.emoji_events),
                      const Divider(height: 24),
                      _infoRow('Стартовый стек', '10 000 очков', Icons.casino),
                      const Divider(height: 24),
                      _infoRow('Уровни', '15 минут', Icons.timer),
                      const Divider(height: 24),
                      _infoRow('Поздняя рег.', 'до 22:00', Icons.access_time),
                      const Divider(height: 24),
                      _infoRow('Re-entry', 'Да', Icons.refresh),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Row(
                children: List.generate(TournamentDetailPage._tabs.length, (index) {
                  return Expanded(
                    child: _TournamentTab(
                      label: TournamentDetailPage._tabs[index],
                      selected: index == _selected,
                      onTap: () => setState(() => _selected = index),
                    ),
                  );
                }),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardLg),
              child: Text(
                TournamentDetailPage._content[_selected],
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: isRegistered
                  ? IosButton(
                      label: 'Перейти к рассадке',
                      filled: false,
                      onPressed: () {
                        context.push('/tournament/${widget.tournamentId}/seating');
                      },
                    )
                  : IosButton(
                      label: 'Зарегистрироваться',
                      onPressed: () => widget._registerAndGoToSeating(
                        context,
                        ref,
                        widget.tournamentId,
                      ),
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _TournamentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TournamentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
