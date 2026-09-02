import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/tournament_card.dart';
import '../widgets/create_tournament_dialog.dart';
import '../widgets/register_players_dialog.dart';
import '../widgets/players_list_dialog.dart';
import '../widgets/tournament_results_dialog.dart';
import '../widgets/rps_settings_dialog.dart';
import '../widgets/season_reset_dialog.dart';
import '../widgets/edit_player_rps_dialog.dart';
import '../../domain/models/tournament_model.dart';
import '../../domain/providers/tournament_provider.dart';
import '../../domain/providers/rps_provider.dart';

class TournamentListScreen extends ConsumerStatefulWidget {
  const TournamentListScreen({super.key});

  @override
  ConsumerState<TournamentListScreen> createState() =>
      _TournamentListScreenState();
}

class _TournamentListScreenState extends ConsumerState<TournamentListScreen> {
  String searchQuery = '';
  String filterStatus = 'all';
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff1D232C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff2A2D35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏆 TournamentListScreen build called');

    // Используем ref.watch вместо ref.read для автоматической перестройки
    final tournaments = ref.watch(tournamentProvider);
    final stats = ref.watch(tournamentProvider.notifier).getStats();

    debugPrint('📊 Tournaments count: ${tournaments.length}');
    debugPrint(
      '📊 Stats: total=${stats.total}, upcoming=${stats.upcoming}, inProgress=${stats.inProgress}, completed=${stats.completed}',
    );

    return Column(
      children: [
        _buildRpsSettingsButton(),
        const SizedBox(height: 16),
        _buildStatsSection(tournaments, stats),
        const SizedBox(height: 24),
        // Search and filters
        _buildSearchAndFiltersSection(),
        const SizedBox(height: 24),
        // Tournaments list - scrollable
        Expanded(
          child: SingleChildScrollView(
            child: _buildTournamentsList(tournaments),
          ),
        ),
      ],
    );
  }

  Widget _buildRpsSettingsButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilledButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const SeasonResetDialog(),
            );
          },
          icon: const Icon(Icons.autorenew),
          label: const Text('Сезонный сброс'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const RpsSettingsDialog(),
            );
          },
          icon: const Icon(Icons.trending_up),
          label: const Text('Настройки RPS'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    List<Tournament> tournaments,
    TournamentStats stats,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              title: 'Всего турниров',
              value: '${stats.total}',
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFF1ABC9C),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: 'Предстоящие',
              value: '${stats.upcoming}',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF3498DB),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: 'Активные',
              value: '${stats.inProgress}',
              icon: Icons.play_circle_rounded,
              color: const Color(0xFFE67E22),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: 'Завершены',
              value: '${stats.completed}',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF95A5A6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFiltersSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Поиск турниров...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xff1D232C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 180,
          decoration: BoxDecoration(
            color: const Color(0xff1D232C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filterStatus,
              icon: const Icon(Icons.filter_list, color: Colors.white54),
              isDense: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              dropdownColor: const Color(0xff1D232C),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Все')),
                DropdownMenuItem(value: 'upcoming', child: Text('Предстоящие')),
                DropdownMenuItem(value: 'inProgress', child: Text('Активные')),
                DropdownMenuItem(value: 'completed', child: Text('Завершены')),
                DropdownMenuItem(value: 'cancelled', child: Text('Отменены')),
              ],
              onChanged: (value) {
                setState(() {
                  filterStatus = value!;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CreateTournamentDialog(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Создать турнир'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1ABC9C),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentsList(List<Tournament> tournaments) {
    // Применяем фильтры
    var filtered = tournaments;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                t.description.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (filterStatus != 'all') {
      filtered = filtered.where((t) => t.status == filterStatus).toList();
    }

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tour_rounded, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'Турниры не найдены',
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filtered.map((tournament) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TournamentCard(
            tournament: tournament,
            onSeating: () =>
                context.push('/tournament/${tournament.id}/seating'),
            onViewPlayers: () {
              showDialog(
                context: context,
                builder: (context) => PlayersListDialog(tournament: tournament),
              );
            },
            onRegister: () {
              showDialog(
                context: context,
                builder: (context) =>
                    RegisterPlayersDialog(tournament: tournament),
              );
            },
            onEdit: () {
              showDialog(
                context: context,
                builder: (context) =>
                    CreateTournamentDialog(tournament: tournament),
              );
            },
            onDelete: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xff1D232C),
                  title: const Text('Удалить турнир?'),
                  content: Text(
                    'Вы уверены, что хотите удалить турнир "${tournament.name}"?',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(tournamentProvider.notifier)
                            .deleteTournament(tournament.id);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Удалить',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            onResults: () {
              showDialog(
                context: context,
                builder: (context) => TournamentResultsDialog(tournament: tournament),
              );
            },
            onRpsSettings: () {
              showDialog(
                context: context,
                builder: (context) => const RpsSettingsDialog(),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
