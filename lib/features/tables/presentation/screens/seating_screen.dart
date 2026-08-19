import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/seating_models.dart';
import '../../domain/providers/seating_provider.dart';

class SeatingScreen extends ConsumerWidget {
  final String tournamentId;

  const SeatingScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(seatingProvider);
    final table = state.selectedTable;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Рассадка игроков'),
            Text(
              'Турнир $tournamentId',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            children: [
              _TableSelector(state: state),
              const SizedBox(height: 16),
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: _TablePanel(table: table)),
                          const SizedBox(width: 16),
                          SizedBox(width: 330, child: _SidePanel(state: state)),
                        ],
                      )
                    : ListView(
                        children: [
                          SizedBox(
                            height: isMobile ? 420 : 500,
                            child: _TablePanel(table: table),
                          ),
                          const SizedBox(height: 16),
                          _SidePanel(state: state),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableSelector extends ConsumerWidget {
  final SeatingState state;

  const _TableSelector({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.tables.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final table = state.tables[index];
                return ChoiceChip(
                  selected: table.id == state.selectedTableId,
                  onSelected: (_) =>
                      ref.read(seatingProvider.notifier).selectTable(table.id),
                  label: Text(
                    '${table.name}  ${table.occupiedCount}/${table.capacity}',
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Добавить стол',
            onPressed: ref.read(seatingProvider.notifier).addTable,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _TablePanel extends StatelessWidget {
  final PokerTable? table;

  const _TablePanel({required this.table});

  @override
  Widget build(BuildContext context) {
    if (table == null) return const Center(child: Text('Стол не выбран'));
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final seatWidth = math.min(118.0, width * .23);
          final seatHeight = 64.0;
          final center = Offset(width / 2, height / 2);
          final radiusX = math.max(90.0, (width - seatWidth) * .39);
          final radiusY = math.max(105.0, (height - seatHeight) * .38);
          return Stack(
            children: [
              Positioned(
                left: width * .17,
                right: width * .17,
                top: height * .26,
                bottom: height * .26,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff12613B),
                    borderRadius: BorderRadius.circular(200),
                    border: Border.all(color: AppColors.gold, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 24),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.casino,
                          color: AppColors.gold,
                          size: 30,
                        ),
                        Text(
                          table!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${table!.occupiedCount} из ${table!.capacity} мест занято',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < table!.seats.length; i++)
                _positionedSeat(
                  context,
                  table!.seats[i],
                  i,
                  table!.seats.length,
                  center,
                  radiusX,
                  radiusY,
                  seatWidth,
                  seatHeight,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _positionedSeat(
    BuildContext context,
    TableSeat seat,
    int index,
    int count,
    Offset center,
    double radiusX,
    double radiusY,
    double width,
    double height,
  ) {
    final angle = -math.pi / 2 + (2 * math.pi * index / count);
    final left = center.dx + math.cos(angle) * radiusX - width / 2;
    final top = center.dy + math.sin(angle) * radiusY - height / 2;
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: _SeatCard(seat: seat),
    );
  }
}

class _SeatCard extends ConsumerWidget {
  final TableSeat seat;

  const _SeatCard({required this.seat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: seat.isOccupied ? AppColors.cardPrimary : AppColors.cardSecondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => seat.isOccupied
            ? _confirmRelease(context, ref)
            : _pickPlayer(context, ref),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seat.isOccupied ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: seat.isOccupied
                    ? AppColors.primary
                    : AppColors.input,
                child: Text('${seat.number}'),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  seat.player?.name ?? 'Свободно',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: seat.isOccupied
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPlayer(BuildContext context, WidgetRef ref) async {
    final players = ref.read(seatingProvider).unseatedPlayers;
    if (players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет нерассаженных игроков')),
      );
      return;
    }
    final selected = await showModalBottomSheet<Player>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text('Выберите игрока'),
              subtitle: Text('Игрок займёт выбранное свободное место'),
            ),
            for (final player in players)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(player.name),
                onTap: () => Navigator.pop(context, player),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      ref.read(seatingProvider.notifier).assignPlayer(selected.id, seat.number);
    }
  }

  Future<void> _confirmRelease(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Освободить место?'),
        content: Text('${seat.player!.name} вернётся в список нерассаженных.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Освободить'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(seatingProvider.notifier).releaseSeat(seat.number);
    }
  }
}

class _SidePanel extends ConsumerWidget {
  final SeatingState state;

  const _SidePanel({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Панель действий',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.unseatedPlayers.isEmpty
                ? null
                : ref.read(seatingProvider.notifier).autoSeat,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Авторассадка'),
          ),
          const SizedBox(height: 20),
          Text(
            'Нерассаженные (${state.unseatedPlayers.length})',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (state.unseatedPlayers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Все игроки рассажены')),
            )
          else
            ...state.unseatedPlayers.map(
              (player) => Card(
                color: AppColors.cardSecondary,
                child: ListTile(
                  dense: true,
                  leading: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 18),
                  ),
                  title: Text(player.name),
                  subtitle: const Text('Нажмите свободное место'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
