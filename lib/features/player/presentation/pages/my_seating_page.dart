import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tables/domain/models/seating_models.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../widgets/screen_widgets.dart';
import '../../domain/providers/tournament_seating_provider.dart';

/// Страница «Моя рассадка» — игрок видит столы и своё место
class MySeatingPage extends ConsumerWidget {
  const MySeatingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAuthUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Пользователь не авторизован'));
        }

        final tournaments = ref.watch(tournamentProvider);
        final registeredTournaments = tournaments
            .where((t) => t.registeredPlayerIds.contains(user.id))
            .toList();

        if (registeredTournaments.isEmpty) {
          return const _EmptySeating();
        }

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: ScreenTitle(title: 'Моя рассадка'),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tournament = registeredTournaments[index];
                  // Загружаем рассадку из API для каждого турнира
                  final seatingAsync = ref.watch(
                    tournamentSeatingProvider(tournament.id),
                  );

                  return seatingAsync.when(
                    data: (tables) {
                      if (tables.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                            vertical: AppSpacing.sm,
                          ),
                          child: IosCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: AppColors.textMuted,
                                      size: 32,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Рассадка ещё не создана',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Администратор создаст рассадку перед турниром',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return _TournamentSeatingCard(
                        tournament: tournament,
                        tables: tables,
                        playerId: user.id,
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                        vertical: AppSpacing.sm,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          'Ошибка загрузки: $error',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  );
                },
                childCount: registeredTournaments.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text('Ошибка загрузки: $error'),
          ],
        ),
      ),
    );
  }
}

class _EmptySeating extends StatelessWidget {
  const _EmptySeating();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: ScreenTitle(title: 'Моя рассадка')),
        SliverToBoxAdapter(
          child: Center(
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
                    Icons.chair_rounded,
                    color: AppColors.textMuted,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Вы не зарегистрированы на турниры',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Зарегистрируйтесь на турнир, чтобы увидеть рассадку',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _TournamentSeatingCard extends StatelessWidget {
  final dynamic tournament;
  final List<PokerTable> tables;
  final String playerId;

  const _TournamentSeatingCard({
    required this.tournament,
    required this.tables,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.accent,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${tournament.registeredPlayerIds.length}/${tournament.maxPlayers} игроков',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTournamentStatus(tournament.status),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Tables grid
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: tables
                    .map(
                      (table) => _PlayerTableWidget(
                        table: table,
                        playerId: playerId,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTournamentStatus(String status) {
    switch (status) {
      case 'upcoming':
        return 'Скоро';
      case 'inProgress':
        return 'Идёт';
      case 'completed':
        return 'Завершён';
      case 'cancelled':
        return 'Отменён';
      default:
        return status;
    }
  }
}

class _PlayerTableWidget extends StatelessWidget {
  final PokerTable table;
  final String playerId;

  const _PlayerTableWidget({
    required this.table,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context) {
    final isMyTable = table.seats.any((seat) => seat.player?.id == playerId);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isMyTable
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.cardSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMyTable ? AppColors.accent : AppColors.border,
          width: isMyTable ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isMyTable
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.input,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.casino_rounded,
                  color: isMyTable ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    table.name,
                    style: TextStyle(
                      color: isMyTable ? AppColors.accent : AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${table.occupiedCount}/${table.capacity}',
                  style: TextStyle(
                    color: isMyTable
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Seats grid
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: table.seats.length,
              itemBuilder: (context, seatIndex) {
                final seat = table.seats[seatIndex];
                final isMySeat = seat.player?.id == playerId;

                return _SeatWidget(seat: seat, isMySeat: isMySeat);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatWidget extends StatelessWidget {
  final TableSeat seat;
  final bool isMySeat;

  const _SeatWidget({
    required this.seat,
    required this.isMySeat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMySeat
            ? AppColors.accent
            : (seat.isOccupied ? AppColors.cardPrimary : AppColors.input),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMySeat
              ? AppColors.goldLight
              : (seat.isOccupied ? AppColors.border : AppColors.border),
          width: isMySeat ? 2.5 : 1,
        ),
        boxShadow: isMySeat
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: seat.isOccupied
            ? Text(
                seat.player!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isMySeat
                      ? AppColors.background
                      : AppColors.white,
                  fontSize: 9,
                  fontWeight: isMySeat ? FontWeight.bold : FontWeight.w500,
                ),
              )
            : Text(
                '${seat.number}',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
