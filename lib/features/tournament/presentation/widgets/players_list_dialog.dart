import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../players/domain/models/admin_player.dart';
import '../../../players/domain/providers/admin_players_provider.dart';
import '../../domain/models/tournament_model.dart';
import '../../domain/providers/tournament_provider.dart';

/// Диалог для просмотра списка зарегистрированных игроков на турнире
class PlayersListDialog extends ConsumerStatefulWidget {
  final Tournament tournament;

  const PlayersListDialog({super.key, required this.tournament});

  @override
  ConsumerState<PlayersListDialog> createState() => _PlayersListDialogState();
}

class _PlayersListDialogState extends ConsumerState<PlayersListDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmPlayer(String playerId, List<AdminPlayer> players) {
    ref.read(tournamentProvider.notifier).confirmPlayer(widget.tournament.id, playerId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getPlayerName(playerId, players)} подтверждён'),
          backgroundColor: const Color(0xFF1ABC9C),
        ),
      );
    }
  }

  void _markPlayerEliminated(String playerId, List<AdminPlayer> players) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff1D232C),
        title: const Text('Перевести в выбывшие?'),
        content: Text(
          'Вы уверены, что хотите отметить "${_getPlayerName(playerId, players)}" как выбывшего?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(tournamentProvider.notifier)
                  .markPlayerEliminated(widget.tournament.id, playerId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Выбыл', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  String _getPlayerName(String playerId, List<AdminPlayer> players) {
    for (final player in players) {
      if (player.id == playerId) return player.name;
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(adminPlayersProvider).players;
    final query = _searchQuery.toLowerCase();
    final filteredPlayers = players.where((player) {
      final isRegistered = widget.tournament.registeredPlayerIds.contains(
        player.id,
      );
      final matchesSearch =
          query.isEmpty ||
          player.name.toLowerCase().contains(query) ||
          player.login.toLowerCase().contains(query) ||
          player.email.toLowerCase().contains(query);
      return isRegistered && matchesSearch;
    }).toList();
    final isFull = widget.tournament.isFull;

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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1ABC9C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    color: Color(0xFF1ABC9C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Зарегистрированные игроки',
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
                  tooltip: 'Закрыть',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff0A0E14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xff2A2D35)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white54, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Записано: ${widget.tournament.currentPlayers}/${widget.tournament.maxPlayers} '
                    '${isFull ? '(Мест нет)' : "(${widget.tournament.maxPlayers - widget.tournament.currentPlayers} мест свободно)"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по имени, логину или email...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xff0A0E14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
            if (filteredPlayers.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Ничего не найдено'
                            : 'Игроки не записаны',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredPlayers.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Color(0xff2A2D35), height: 1),
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
                    final indexInTournament = widget
                        .tournament
                        .registeredPlayerIds
                        .indexOf(player.id);
                    final isConfirmed = widget.tournament.isPlayerConfirmed(player.id);
                    final isEliminated = widget.tournament.isPlayerEliminated(player.id);
                    final initial = player.login.isNotEmpty
                        ? player.login[0].toUpperCase()
                        : '?';

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: isEliminated
                            ? Colors.redAccent
                            : (isConfirmed ? const Color(0xFF1ABC9C) : const Color(0xFFD4A017)),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '@${player.login} • ${player.email}\n'
                        '${player.rank.label} • ${player.rpsPoints > 0 ? player.rpsPoints.toString() : '—'} очков',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (indexInTournament >= 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1ABC9C,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#${indexInTournament + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF1ABC9C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          if (!isEliminated)
                            IconButton(
                              onPressed: () => _markPlayerEliminated(player.id, players),
                              icon: const Icon(
                                Icons.person_off_outlined,
                                color: Colors.orange,
                                size: 20,
                              ),
                              tooltip: 'Выбыл',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                              ),
                            ),
                          if (!isConfirmed && !isEliminated)
                            IconButton(
                              onPressed: () => _confirmPlayer(player.id, players),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF1ABC9C),
                                size: 20,
                              ),
                              tooltip: 'Подтвердить гостя',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF1ABC9C).withValues(alpha: 0.1),
                              ),
                            ),
                          if (isEliminated)
                            const Icon(
                              Icons.flag_rounded,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          if (isConfirmed && !isEliminated)
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF1ABC9C),
                              size: 18,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
