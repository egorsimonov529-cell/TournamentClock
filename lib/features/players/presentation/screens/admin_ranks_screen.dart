import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/rank_definition.dart';
import '../../domain/providers/admin_players_provider.dart';
import '../../domain/providers/ranks_provider.dart';

class AdminRanksScreen extends ConsumerWidget {
  const AdminRanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranks = ref.watch(ranksProvider);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _edit(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Создать ранг'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ranks.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Не удалось загрузить ранги: $error',
              ),
            ),
            data: (items) => items.isEmpty
                ? const Center(
                    child: Text('Список рангов пуст'),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final rank = items[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(rank.name),
                        subtitle: Text(
                          '${rank.code} — от ${rank.minimumPoints} очков${rank.description.isEmpty ? '' : '\n${rank.description}'}',
                        ),
                        isThreeLine: rank.description.isNotEmpty,
                        trailing: Wrap(
                          children: [
                            IconButton(
                              tooltip: 'Редактировать',
                              onPressed: () => _edit(context, ref, rank),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Удалить',
                              onPressed: () => _delete(context, ref, rank),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    RankDefinition? rank,
  ]) async {
    final code = TextEditingController(text: rank?.code ?? '');
    final name = TextEditingController(text: rank?.name ?? '');
    final points = TextEditingController(
      text: rank?.minimumPoints.toString() ?? '0',
    );
    final description = TextEditingController(text: rank?.description ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          rank == null ? 'Новый ранг' : 'Редактирование ранга',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: code,
                enabled: rank == null,
                decoration: const InputDecoration(labelText: 'Код'),
              ),
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Название',
                ),
              ),
              TextField(
                controller: points,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Минимум очков',
                ),
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;
    final normalized = code.text.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_-]'),
      '-',
    );
    final title = name.text.trim();
    final minimum = int.tryParse(points.text.trim());
    if (normalized.isEmpty || title.isEmpty || minimum == null || minimum < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Заполните код, название и корректное число очков',
          ),
        ),
      );
      return;
    }
    final existing =
        ref.read(ranksProvider).valueOrNull ?? const <RankDefinition>[];
    if (rank == null && existing.any((item) => item.code == normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ранг с таким кодом уже существует',
          ),
        ),
      );
      return;
    }
    await ref
        .read(ranksProvider.notifier)
        .upsert(
          RankDefinition(
            id: rank?.id ?? 'rank-$normalized',
            code: rank?.code ?? normalized,
            name: title,
            minimumPoints: minimum,
            description: description.text.trim(),
          ),
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RankDefinition rank,
  ) async {
    final assigned = ref
        .read(adminPlayersProvider)
        .players
        .where((player) => player.rank.name == rank.code)
        .length;
    if (assigned > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Нельзя удалить ранг: он назначен игрокам ($assigned)',
          ),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить ранг?'),
        content: Text(
          'Ранг “${rank.name}” будет удалён без возможности восстановления.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(ranksProvider.notifier).remove(rank.id);
    }
  }
}
