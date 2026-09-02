import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/providers/rps_provider.dart';

class RpsSettingsDialog extends ConsumerStatefulWidget {
  const RpsSettingsDialog({super.key});

  @override
  ConsumerState<RpsSettingsDialog> createState() => _RpsSettingsDialogState();
}

class _RpsSettingsDialogState extends ConsumerState<RpsSettingsDialog> {
  late TextEditingController _ratingPerRpsController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(rpsProvider).settings ?? const RpsSettings(ratingPerRps: 10);
    _ratingPerRpsController = TextEditingController(text: settings.ratingPerRps.toString());
  }

  @override
  void dispose() {
    _ratingPerRpsController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final ratingPerRps = int.tryParse(_ratingPerRpsController.text.trim()) ?? 10;

    final settings = RpsSettings(ratingPerRps: ratingPerRps);

    try {
      await ref.read(rpsProvider.notifier).saveSettings(settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Настройки сохранены'),
            backgroundColor: AppColors.accent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
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
            const Text(
              'Настройки RPS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'За каждые N очков рейтинга начисляется 1 RPS',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            // Rating per RPS
            TextField(
              controller: _ratingPerRpsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Очков рейтинга за 1 RPS',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: '10',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.background,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'Пример: при значении 10, игрок получает 1 RPS за каждые 10 очков рейтинга',
              style: TextStyle(color: Colors.white54, fontSize: 11),
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
                  onPressed: _saveSettings,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
