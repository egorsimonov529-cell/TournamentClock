import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/tournament_model.dart';
import '../../domain/providers/tournament_provider.dart';

/// Диалог для просмотра списка зарегистрированных игроков на турнире
class PlayersListDialog extends ConsumerStatefulWidget {
  final Tournament tournament;

  const PlayersListDialog({
    super.key,
    required this.tournament,
  });

  @override
  ConsumerState<PlayersListDialog> createState() => _PlayersListDialogState();
}

class _PlayersListDialogState extends ConsumerState<PlayersListDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock players data (такие же как в RegisterPlayersDialog)
  final List<_MockPlayer> _allPlayers = const [
    _MockPlayer('player1', 'Alex_Pok', 'Alexey Ivanov'),
    _MockPlayer('player2', 'PokerKing', 'Dmitry Petrov'),
    _MockPlayer('player3', 'Sniper777', 'Maxim Sidorov'),
    _MockPlayer('player4', 'LuckyLady', 'Anna Kuznetsova'),
    _MockPlayer('player5', 'DiamondHands', 'Igor Volkov'),
    _MockPlayer('player6', 'BluffMaster', 'Elena Smirnova'),
    _MockPlayer('player7', 'FoldEquity', 'Sergey Popov'),
    _MockPlayer('player8', 'AceHigh', 'Maria Sokolova'),
    _MockPlayer('player9', 'RiverShark', 'Vladimir Morozov'),
    _MockPlayer('player10', 'Nutation', 'Oleg Vasilev'),
  ];

  List<_MockPlayer> get _filteredPlayers {
    var all = _allPlayers.where((p) {
      return widget.tournament.registeredPlayerIds.contains(p.id);
    }).toList();

    if (_searchQuery.isEmpty) return all;
    
    return all.where((p) =>
      p.login.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removePlayer(String playerId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff1D232C),
        title: const Text('Удалить игрока?'),
        content: Text(
          'Вы уверены, что хотите удалить игрока "${_getPlayerName(playerId)}" из турнира?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tournamentProvider.notifier).removePlayer(
                widget.tournament.id,
                playerId,
              );
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Close players list dialog
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlayerName(String playerId) {
    final player = _allPlayers.firstWhere(
      (p) => p.id == playerId,
      orElse: () => const _MockPlayer('', '', 'Unknown'),
    );
    return player.name;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = _filteredPlayers;
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
                    color: const Color(0xFF1ABC9C).withOpacity(0.1),
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
                  Icon(
                    Icons.info_outline,
                    color: Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Записано: ${widget.tournament.currentPlayers}/${widget.tournament.maxPlayers} '
                    '${isFull ? '(Мест нет)' : "(${widget.tournament.maxPlayers - widget.tournament.currentPlayers} мест свободно)"}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xff2A2D35),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
                    final indexInTournament = widget.tournament
                        .registeredPlayerIds
                        .indexOf(player.id);

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1ABC9C),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        player.login,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
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
                                color: const Color(0xFF1ABC9C).withOpacity(0.1),
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
                          IconButton(
                            onPressed: () => _removePlayer(player.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            tooltip: 'Удалить из турнира',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.1),
                            ),
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

class _MockPlayer {
  final String id;
  final String login;
  final String name;

  const _MockPlayer(this.id, this.login, this.name);
}
