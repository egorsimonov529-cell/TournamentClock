import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // Mock players data
  final List<_MockPlayer> _allPlayers = const [
    _MockPlayer('player1', 'Alex_Pok', 'Alexey Ivanov'),
    _MockPlayer('player2', ' PokerKing', 'Dmitry Petrov'),
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
    if (_searchQuery.isEmpty) return _allPlayers;
    return _allPlayers.where((p) =>
      p.login.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<String> get _registeredIds => widget.tournament.registeredPlayerIds;

  bool _isRegistered(String playerId) {
    return _registeredIds.contains(playerId);
  }

  void _togglePlayer(String playerId) {
    if (_isRegistered(playerId)) {
      ref.read(tournamentProvider.notifier).removePlayer(
        widget.tournament.id,
        playerId,
      );
    } else {
      if (widget.tournament.currentPlayers < widget.tournament.maxPlayers) {
        ref.read(tournamentProvider.notifier).registerPlayer(
          widget.tournament.id,
          playerId,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                itemCount: _filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = _filteredPlayers[index];
                  final registered = _isRegistered(player.id);

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
                        color: registered
                            ? Colors.greenAccent
                            : Colors.white54,
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
                  'Записано: ${widget.tournament.currentPlayers}/${widget.tournament.maxPlayers}',
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

class _MockPlayer {
  final String id;
  final String login;
  final String name;

  const _MockPlayer(this.id, this.login, this.name);
}
