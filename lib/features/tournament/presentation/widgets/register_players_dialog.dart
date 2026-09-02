import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../players/domain/providers/admin_players_provider.dart';
import '../../domain/models/tournament_model.dart';
import '../../domain/providers/tournament_provider.dart';

class RegisterPlayersDialog extends ConsumerStatefulWidget {
  final Tournament tournament;

  const RegisterPlayersDialog({super.key, required this.tournament});

  @override
  ConsumerState<RegisterPlayersDialog> createState() =>
      _RegisterPlayersDialogState();
}

class _RegisterPlayersDialogState extends ConsumerState<RegisterPlayersDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Tournament? get _currentTournament {
    for (final tournament in ref.read(tournamentProvider)) {
      if (tournament.id == widget.tournament.id) return tournament;
    }
    return null;
  }

  List<String> get _registeredIds =>
      _currentTournament?.registeredPlayerIds ?? const [];

  bool _isRegistered(String playerId) => _registeredIds.contains(playerId);

  Future<void> _togglePlayer(String playerId) async {
    final wasRegistered = _isRegistered(playerId);
    final notifier = ref.read(tournamentProvider.notifier);
    
    TournamentRegistrationResult result;
    if (wasRegistered) {
      final removed = await notifier.removePlayer(widget.tournament.id, playerId);
      result = removed 
          ? TournamentRegistrationResult.success 
          : TournamentRegistrationResult.notFound;
    } else {
      result = await notifier.registerPlayer(widget.tournament.id, playerId);
    }

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == TournamentRegistrationResult.success
              ? wasRegistered
                    ? 'Игрок удалён из турнира'
                    : 'Игрок записан на турнир'
              : 'Ошибка: ${result?.message ?? "неизвестная ошибка"}',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(adminPlayersProvider).players;
    final tournaments = ref.watch(tournamentProvider);
    final currentTournament = tournaments
        .where((tournament) => tournament.id == widget.tournament.id)
        .firstOrNull;
    final query = _searchQuery.trim().toLowerCase();
    final filteredPlayers = query.isEmpty
        ? players
        : players
              .where(
                (player) =>
                    player.login.toLowerCase().contains(query) ||
                    player.name.toLowerCase().contains(query),
              )
              .toList();

    return Dialog(
      backgroundColor: const Color(0xff1D232C),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.person_add,
                  color: Color(0xFF1ABC9C),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Запись игроков на турнир',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.tournament.name,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по логину или имени...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xff0A0E14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Players list
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = filteredPlayers[index];
                  final registered =
                      currentTournament?.registeredPlayerIds.contains(
                        player.id,
                      ) ??
                      false;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: registered
                          ? const Color(0xFF1ABC9C)
                          : const Color(0xff2A2D35),
                      child: Text(
                        player.login[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      player.login,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: FilledButton.tonalIcon(
                      onPressed: () => _togglePlayer(player.id),
                      icon: Icon(
                        registered
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        color: registered ? Colors.greenAccent : Colors.white54,
                      ),
                      label: Text(
                        registered ? 'Записан' : 'Записать',
                        style: TextStyle(
                          color: registered
                              ? Colors.greenAccent
                              : Colors.white70,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Записано: ${currentTournament?.currentPlayers ?? widget.tournament.currentPlayers}/${currentTournament?.maxPlayers ?? widget.tournament.maxPlayers}',
                  style: const TextStyle(color: Colors.white54),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1ABC9C),
                  ),
                  child: const Text('Готово'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
