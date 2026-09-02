import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/providers/rps_provider.dart';
import '../../domain/providers/tournament_provider.dart';
import '../../domain/models/tournament_model.dart';

class TournamentResultsDialog extends ConsumerStatefulWidget {
  final Tournament tournament;

  const TournamentResultsDialog({super.key, required this.tournament});

  @override
  ConsumerState<TournamentResultsDialog> createState() => _TournamentResultsDialogState();
}

class _TournamentResultsDialogState extends ConsumerState<TournamentResultsDialog> {
  final List<TextEditingController> _positionControllers = [];
  final List<TextEditingController> _ratingControllers = [];

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры для каждого зарегистрированного игрока
    for (var i = 0; i < widget.tournament.registeredPlayerIds.length; i++) {
      _positionControllers.add(TextEditingController());
      _ratingControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _positionControllers) {
      controller.dispose();
    }
    for (var controller in _ratingControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _distributeResults() async {
    // Собираем данные из полей
    final results = <Map<String, dynamic>>[];
    
    for (var i = 0; i < widget.tournament.registeredPlayerIds.length; i++) {
      final playerId = widget.tournament.registeredPlayerIds[i];
      final positionText = _positionControllers[i].text.trim();
      final ratingText = _ratingControllers[i].text.trim();

      if (positionText.isEmpty || ratingText.isEmpty) {
        continue;
      }

      final position = int.tryParse(positionText);
      final rating = int.tryParse(ratingText);

      if (position == null || rating == null) {
        continue;
      }

      results.add({
        'userId': playerId,
        'position': position,
        'ratingEarned': rating,
      });
    }

    if (results.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заполните хотя бы одну строку'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Отправляем на сервер
    final success = await ref.read(rpsProvider.notifier).distributeResults(
          widget.tournament.id,
          results,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Рейтинг и RPS распределены'),
            backgroundColor: AppColors.accent,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка распределения результатов'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.tournament.registeredPlayerIds;

    return Dialog(
      backgroundColor: AppColors.surface,
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Результаты турнира',
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
            const SizedBox(height: 8),
            Text(
              widget.tournament.name,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Введите позицию и рейтинг. RPS начисляется автоматически (1 RPS за 10 очков рейтинга)',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            // Таблица с результатами
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Заголовок таблицы
                    Row(
                      children: [
                        SizedBox(width: 60, child: const Text('Игрок', style: TextStyle(color: Colors.white70, fontSize: 12))),
                        const SizedBox(width: 12),
                        SizedBox(width: 70, child: const Text('#', style: TextStyle(color: Colors.white70, fontSize: 12))),
                        const SizedBox(width: 12),
                        SizedBox(width: 120, child: const Text('Рейтинг', style: TextStyle(color: Colors.white70, fontSize: 12))),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('RPS (авто)', style: TextStyle(color: Colors.white70, fontSize: 12))),
                      ],
                    ),
                    const Divider(color: AppColors.border),
                    // Строки с игроками
                    ...players.asMap().entries.map((entry) {
                      final index = entry.key;
                      final playerId = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                'Игрок ${index + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                controller: _positionControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '#',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _ratingControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '0',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '',
                                style: const TextStyle(color: AppColors.accent, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
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
                  onPressed: _distributeResults,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Распределить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
