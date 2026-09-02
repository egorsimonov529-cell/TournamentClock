import 'package:flutter/material.dart';

import '../../domain/models/tournament_model.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onRegister;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewPlayers;
  final VoidCallback onSeating;
  final VoidCallback onResults;
  final VoidCallback onRpsSettings;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onRegister,
    required this.onEdit,
    required this.onDelete,
    required this.onViewPlayers,
    required this.onSeating,
    required this.onResults,
    required this.onRpsSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff2A2D35), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1ABC9C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFF1ABC9C),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                      tournament.statusColor.replaceAll(
                                        '#',
                                        '',
                                      ),
                                      radix: 16,
                                    ) |
                                    0xFF000000,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tournament.statusDisplay,
                              style: TextStyle(
                                color: Color(
                                  int.parse(
                                        tournament.statusColor.replaceAll(
                                          '#',
                                          '',
                                        ),
                                        radix: 16,
                                      ) |
                                      0xFF000000,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${tournament.startDate.day.toString().padLeft(2, '0')}.${tournament.startDate.month.toString().padLeft(2, '0')}.${tournament.startDate.year} - ${tournament.endDate.day.toString().padLeft(2, '0')}.${tournament.endDate.month.toString().padLeft(2, '0')}.${tournament.endDate.year}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              tournament.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.people_rounded,
                  value:
                      '${tournament.currentPlayers}/${tournament.maxPlayers}',
                  label: 'Игроки',
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  icon: Icons.payment_rounded,
                  value: '₽${tournament.buyIn.toInt()}',
                  label: 'Взнос',
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  icon: Icons.format_list_bulleted_rounded,
                  value: tournament.format,
                  label: 'Формат',
                ),
                const Spacer(),
                // Progress bar
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: tournament.maxPlayers > 0
                            ? tournament.currentPlayers / tournament.maxPlayers
                            : 0,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                        backgroundColor: const Color(0xff2A2D35),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1ABC9C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tournament.isFull
                            ? 'Мест нет'
                            : '${tournament.maxPlayers - tournament.currentPlayers} мест свободно',
                        style: TextStyle(
                          color: tournament.isFull
                              ? Colors.redAccent
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onRpsSettings,
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: const Text('Настройки RPS'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onResults,
                  icon: const Icon(Icons.emoji_events, size: 18),
                  label: const Text('Результаты'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1ABC9C),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onSeating,
                  icon: const Icon(Icons.event_seat, size: 18),
                  label: const Text('Рассадка'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFC9A84E),
                  ),
                ),
                const SizedBox(width: 8),
                if (tournament.currentPlayers > 0)
                  TextButton.icon(
                    onPressed: onViewPlayers,
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: Text('Игроки (${tournament.currentPlayers})'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1ABC9C),
                    ),
                  ),
                if (tournament.currentPlayers > 0 &&
                    tournament.status == 'upcoming')
                  const SizedBox(width: 8),
                if (tournament.status == 'upcoming')
                  TextButton.icon(
                    onPressed: onRegister,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Записать'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3498DB),
                    ),
                  ),
                if (tournament.status != 'completed')
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Редактировать'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Удалить'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
