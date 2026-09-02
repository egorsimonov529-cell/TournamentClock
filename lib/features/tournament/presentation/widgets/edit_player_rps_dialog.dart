import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/models/rps_rank.dart';
import '../../domain/providers/rps_provider.dart';
import '../../../../features/players/domain/providers/admin_players_provider.dart';

class EditPlayerRpsDialog extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;
  final int currentRps;
  final RpsRank currentRank;

  const EditPlayerRpsDialog({
    super.key,
    required this.playerId,
    required this.playerName,
    required this.currentRps,
    required this.currentRank,
  });

  @override
  ConsumerState<EditPlayerRpsDialog> createState() => _EditPlayerRpsDialogState();
}

class _EditPlayerRpsDialogState extends ConsumerState<EditPlayerRpsDialog> {
  late TextEditingController _rpsController;
  late TextEditingController _reasonController;
  RpsRank _selectedRank = RpsRank.fish;

  @override
  void initState() {
    super.initState();
    _rpsController = TextEditingController(text: widget.currentRps.toString());
    _reasonController = TextEditingController();
    _selectedRank = widget.currentRank;
  }

  @override
  void dispose() {
    _rpsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _updateRankFromRps() {
    final rps = int.tryParse(_rpsController.text.trim()) ?? 0;
    if (rps >= 800) _selectedRank = RpsRank.platinum;
    else if (rps >= 600) _selectedRank = RpsRank.gold;
    else if (rps >= 400) _selectedRank = RpsRank.silver;
    else if (rps >= 200) _selectedRank = RpsRank.bronze;
    else _selectedRank = RpsRank.fish;
  }

  Future<void> _saveRps() async {
    final rps = int.tryParse(_rpsController.text.trim()) ?? widget.currentRps;
    final reason = _reasonController.text.trim();

    try {
      final success = await ref.read(rpsProvider.notifier).editPlayerRps(
            widget.playerId,
            rps,
            reason: reason,
          );

      if (mounted) {
        if (success) {
          // Reload admin players to sync changes across all screens (leaderboard, etc.)
          await ref.read(adminPlayersProvider.notifier).load();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'RPS изменён: ${widget.currentRps} → ${rps} (${_selectedRank.label})',
              ),
              backgroundColor: AppColors.accent,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка сохранения'),
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
                  'Изменить RPS',
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
              widget.playerName,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // RPS input
            TextField(
              controller: _rpsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'RPS очки',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => _updateRankFromRps(),
            ),
            const SizedBox(height: 12),
            // Rank selector
            TextField(
              controller: TextEditingController(text: _selectedRank.label),
              decoration: InputDecoration(
                labelText: 'Ранг',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.background,
                border: const OutlineInputBorder(),
                suffixIcon: DropdownButton<RpsRank>(
                  value: _selectedRank,
                  underline: const SizedBox(),
                  items: RpsRank.values.map((rank) {
                    return DropdownMenuItem(
                      value: rank,
                      child: Text(
                        rank.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (rank) {
                    if (rank != null) {
                      setState(() {
                        _selectedRank = rank;
                        _rpsController.text = rank.baseScore.toString();
                      });
                    }
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            // Reason
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
                  onPressed: _saveRps,
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
