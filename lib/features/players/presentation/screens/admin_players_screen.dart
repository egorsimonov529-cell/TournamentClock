import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../domain/models/admin_player.dart';
import '../../domain/providers/admin_players_provider.dart';
import '../widgets/admin_player_profile_dialog.dart';
import '../../../tournament/presentation/widgets/edit_player_rps_dialog.dart';

class AdminPlayersScreen extends ConsumerStatefulWidget {
  const AdminPlayersScreen({super.key});

  @override
  ConsumerState<AdminPlayersScreen> createState() => _AdminPlayersScreenState();
}

class _AdminPlayersScreenState extends ConsumerState<AdminPlayersScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminPlayersProvider);
    final players = state.players.where((player) {
      final value = query.toLowerCase();
      return player.name.toLowerCase().contains(value) ||
          player.login.toLowerCase().contains(value);
    }).toList();
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Поиск игрока...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) => setState(() => query = value),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: state.isLoading && state.players.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.error != null && state.players.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Не удалось загрузить игроков: ${state.error}'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref
                            .read(adminPlayersProvider.notifier)
                            .load(),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : players.isEmpty
              ? const Center(child: Text('Игроки не найдены'))
              : ListView.separated(
                  itemCount: players.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _PlayerTile(player: players[index]),
                ),
        ),
      ],
    );
  }
}

class _PlayerTile extends ConsumerWidget {
  final AdminPlayer player;
  const _PlayerTile({required this.player, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: ListTile(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AdminPlayerProfileDialog(playerId: player.id),
      ),
      leading: CircleAvatar(child: Text(player.login[0].toUpperCase())),
      title: Text(player.name),
      subtitle: Text('@${player.login} • ${player.email} • Рейтинг: ${player.rating} • ${player.rpsPoints} RPS (${player.rank.label})'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          onPressed: () async {
            showDialog(
              context: context,
              builder: (_) => EditPlayerRpsDialog(
                playerId: player.id,
                playerName: player.name,
                currentRps: player.rpsPoints,
                currentRank: player.rank,
              ),
            );
          },
          icon: const Icon(Icons.edit_rounded),
          tooltip: 'Изменить RPS',
        ),
        IconButton(
          onPressed: () async {
            final amountCtrl = TextEditingController();
            final reasonCtrl = TextEditingController();
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Добавить рейтинг'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сколько добавить')),
                    TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Причина (опционально)')),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Добавить')),
                ],
              ),
            );
            if (ok != true) return;
            final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
            if (amount == 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Некорректная сумма')));
              return;
            }
            try {
              await ref.read(adminPlayersProvider.notifier).addRating(player.id, amount, reason: reasonCtrl.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Рейтинг успешно обновлён')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
            }
          },
          icon: const Icon(Icons.add_chart_rounded),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right),
      ]),
    ),
  );
}
