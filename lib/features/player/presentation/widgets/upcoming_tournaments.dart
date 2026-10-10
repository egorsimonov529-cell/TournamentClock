import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../../../tournament/domain/models/tournament_model.dart';

class UpcomingTournaments extends StatelessWidget {
  final VoidCallback onOpenTournaments;

  const UpcomingTournaments({super.key, required this.onOpenTournaments});

  @override
  Widget build(BuildContext context) {
    List<Tournament> tournaments = [];
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final data = container.read(tournamentProvider);
      tournaments = data;
    } catch (_) {
      tournaments = [];
    }

    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 420;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : width < 650 ? 16 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              const Text(
                "Ближайшие турниры",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onOpenTournaments,
                child: Text(
                  "Все турниры",
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tournaments.isEmpty)
            const Text('Турниров пока нет', style: TextStyle(color: Colors.white54))
          else ...[
            for (var i = 0; i < (tournaments.length < 3 ? tournaments.length : 3); i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTournamentItem(tournaments[i], onOpenTournaments),
              ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTournamentItem(Tournament t, VoidCallback onOpen) {
    final name = t.name;
    final date = '${t.startDate.day.toString().padLeft(2, "0")} ${_month(t.startDate.month)} ${t.startDate.hour.toString().padLeft(2, "0")}:${t.startDate.minute.toString().padLeft(2, "0")}';
    final buyIn = 'Взнос ${t.buyIn.toStringAsFixed(0)} ₽';
    final prizePool = t.format;
    final spots = '${t.currentPlayers}/${t.maxPlayers}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff2A2D35), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;

          return Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment:
                isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isNarrow) ...[
                const SizedBox(width: 24),
                _buildMiniInfo("Взнос", buyIn),
                const SizedBox(width: 24),
                _buildMiniInfo("Рейтинг", prizePool),
                const SizedBox(width: 24),
                _buildMiniInfo("Места", spots),
                const SizedBox(width: 16),
              ] else ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildMiniInfo("Взнос", buyIn),
                    _buildMiniInfo("Рейтинг", prizePool),
                    _buildMiniInfo("Места", spots),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 84,
                  maxWidth: 104,
                ),
                child: SizedBox(
                  width: 90,
                  child: ElevatedButton(
                    onPressed: onOpen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Участвовать",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _month(int m) {
    const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return months[(m - 1).clamp(0, 11)];
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
