import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/achievement_admin_card.dart';
import '../widgets/achievement_form_dialog.dart';
import '../../domain/models/achievement.dart';
import '../../domain/providers/achievements_providers.dart';

class AdminAchievementsScreen extends ConsumerWidget {
  const AdminAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(achievementsListProvider);

    return asyncList.when(
      data: (list) {
        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => const AchievementFormDialog(),
                  );
                  ref.refresh(achievementsListProvider);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Добавить достижение'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final achievement = list[index];
                  return AchievementAdminCard(
                    achievement: achievement,
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Подтвердите удаление'),
                          content: const Text('Вы уверены, что хотите удалить это достижение?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      try {
                        await ref.read(deleteAchievementUsecaseProvider).call(achievement.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Достижение удалено')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: ${e.toString()}')));
                      }
                      ref.refresh(achievementsListProvider);
                    },
                    onEdit: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => AchievementFormDialog(achievement: achievement, remoteId: achievement.id),
                      );
                      ref.refresh(achievementsListProvider);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Ошибка загрузки достижений')),
    );
  }
}
