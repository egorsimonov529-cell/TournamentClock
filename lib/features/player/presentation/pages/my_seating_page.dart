import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tables/domain/providers/seating_provider.dart';
import '../../../tables/domain/models/seating_models.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../widgets/screen_widgets.dart';

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
                  // Используем seatingProvider с логикой бронирования
                  final seatingState = ref.watch(
                    seatingProvider(tournament.id),
                  );

                  return _TournamentSeatingCard(
                    tournament: tournament,
                    seatingState: seatingState,
                    playerId: user.id,
                    tournamentId: tournament.id,
                    ref: ref,
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
  final SeatingState seatingState;
  final String playerId;
  final String tournamentId;
  final WidgetRef ref;

  const _TournamentSeatingCard({
    required this.tournament,
    required this.seatingState,
    required this.playerId,
    required this.tournamentId,
    required this.ref,
  });

  SeatingNotifier _getNotifier() {
    return ref.read(seatingProvider(tournamentId).notifier);
  }

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
                      _getTournamentStatus(tournament.effectiveStatus),
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
            // Refresh button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.card, vertical: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(seatingProvider(tournament.id).notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Обновить'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ),
            // Tables grid
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: seatingState.tables
                    .map(
                      (table) => _PlayerTableWidget(
                        table: table,
                        playerId: playerId,
                        tournamentId: tournamentId,
                        selectedTableId: seatingState.selectedTableId,
                        notifier: _getNotifier(),
                        onTableSelected: (tableId) {
                          _getNotifier().selectTable(tableId);
                        },
                        onSeatBooked: () {
                          // Перезагружаем состояние после бронирования
                          _getNotifier().refresh();
                        },
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

class _PlayerTableWidget extends StatefulWidget {
  final PokerTable table;
  final String playerId;
  final String tournamentId;
  final String selectedTableId;
  final SeatingNotifier notifier;
  final Function(String) onTableSelected;
  final VoidCallback onSeatBooked;

  const _PlayerTableWidget({
    required this.table,
    required this.playerId,
    required this.tournamentId,
    required this.selectedTableId,
    required this.notifier,
    required this.onTableSelected,
    required this.onSeatBooked,
  });

  @override
  State<_PlayerTableWidget> createState() => _PlayerTableWidgetState();
}

class _PlayerTableWidgetState extends State<_PlayerTableWidget> {
  bool _booking = false;

  Future<void> _bookSeat(int seatNumber) async {
    // Проверяем, заблокировано ли место
    if (widget.notifier.isSeatLocked(widget.table.id, seatNumber)) return;
    if (_booking) return;
    
    setState(() => _booking = true);
    final success = await widget.notifier.bookSeat(seatNumber, tableId: widget.table.id);
    setState(() => _booking = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Место ${seatNumber} забронировано'),
          backgroundColor: AppColors.primary,
        ),
      );
      widget.onSeatBooked();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось забронировать место'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _cancelSeat(int seatNumber) async {
    // Проверяем, заблокировано ли место
    if (widget.notifier.isSeatLocked(widget.table.id, seatNumber)) return;
    
    final success = await widget.notifier.cancelSeat(seatNumber);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бронирование отменено'),
          backgroundColor: AppColors.primary,
        ),
      );
      widget.onSeatBooked();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyTable = widget.table.seats.any((seat) => seat.player?.id == widget.playerId);
    final isSelected = widget.selectedTableId == widget.table.id;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isMyTable
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.cardSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.accent : (isMyTable ? AppColors.accent : AppColors.border),
          width: isSelected ? 2.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
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
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.table.name,
                    style: TextStyle(
                      color: isSelected ? AppColors.accent : AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${widget.table.occupiedCount}/${widget.table.capacity}',
                  style: TextStyle(
                    color: isSelected
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
              itemCount: widget.table.seats.length,
              itemBuilder: (context, seatIndex) {
                final seat = widget.table.seats[seatIndex];
                final isMySeat = seat.player?.id == widget.playerId;
                final isLocked = widget.notifier.isSeatLocked(
                  widget.table.id,
                  seat.number,
                );
                final isFree = seat.status == SeatStatus.free;

                return _SeatWidget(
                  seat: seat,
                  isMySeat: isMySeat,
                  isFree: isFree,
                  onBook: isFree ? () => _bookSeat(seat.number) : null,
                  onCancel: isMySeat ? () => _cancelSeat(seat.number) : null,
                  booking: _booking,
                  isLocked: isLocked,
                );
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
  final bool isFree;
  final VoidCallback? onBook;
  final VoidCallback? onCancel;
  final bool booking;
  final bool isLocked;

  const _SeatWidget({
    required this.seat,
    required this.isMySeat,
    required this.isFree,
    this.onBook,
    this.onCancel,
    this.booking = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = !isLocked && !booking && ((isMySeat && onCancel != null) || (isFree && onBook != null));

    return GestureDetector(
      onTap: () {
        if (isLocked || booking) return;
        if (isMySeat && onCancel != null) {
          onCancel!();
        } else if (isFree && onBook != null) {
          onBook!();
        }
      },
      child: Container(
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
          child: isLocked
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textMuted,
                    ),
                  ),
                )
              : seat.isOccupied
                  ? Text(
                      seat.player!.nickname?.isNotEmpty == true
                          ? seat.player!.nickname!
                          : seat.player!.login,
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
                        color: isInteractive
                            ? AppColors.accent
                            : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
        ),
      ),
    );
  }
}
