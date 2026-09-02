import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/providers/rps_provider.dart';

class SeasonResetDialog extends ConsumerStatefulWidget {
  const SeasonResetDialog({super.key});

  @override
  ConsumerState<SeasonResetDialog> createState() => _SeasonResetDialogState();
}

class _SeasonResetDialogState extends ConsumerState<SeasonResetDialog> {
  late TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Подтвердите сезонный сброс'),
        content: const Text(
          'Все игроки будут переведены на базовый уровень текущего ранга.\n\n'
          'Например: игрок с 240 RPS (Bronze) получит 200 RPS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await ref.read(rpsProvider.notifier).seasonReset(
            reason: _reasonController.text.trim(),
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Сезонный сброс выполнен'),
              backgroundColor: AppColors.accent,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка сброса'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Сезонный сброс RPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Как работает сброс:',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• RPS сбрасывается до базового значения текущего ранга\n'
                    '• Fish (0): 0 RPS\n'
                    '• Bronze (200): 200 RPS\n'
                    '• Silver (400): 400 RPS\n'
                    '• Gold (600): 600 RPS\n'
                    '• Platinum (800): 800 RPS\n\n'
                    'Пример: игрок с 240 RPS (Bronze) → 200 RPS',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Причина (опционально)',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _confirmReset,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Сбросить RPS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
