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
import '../../domain/models/tournament_model.dart';
import '../../domain/providers/tournament_provider.dart';
import '../../../../core/services/api_service.dart';

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
    return Container(
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

    final rows = _buildTournamentsList(tournaments);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff101418),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRpsSettingsButton(),
              const SizedBox(height: 16),
              _buildStatsSection(tournaments, stats),
              const SizedBox(height: 24),
              _buildSearchAndFiltersSection(),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) => rows[index],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRpsSettingsButton() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: _syncTournamentLifecycle,
          icon: const Icon(Icons.sync_rounded),
          label: const Text('Синхронизировать статусы'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2E86DE),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        FilledButton.icon(
          onPressed: _startNearestTournament,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Запустить ближайший'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF27AE60),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        FilledButton.icon(
          onPressed: () => _showBulkNotificationDialog(),
          icon: const Icon(Icons.notifications_active_rounded),
          label: const Text('Рассылка уведомлений'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE67E22),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
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

  Future<void> _syncTournamentLifecycle() async {
    try {
      final response = await ApiService().post('/tournaments/reconcile');
      final body = response.data as Map<String, dynamic>? ?? const {};
      final started = body['started'] ?? 0;
      final finished = body['finished'] ?? 0;
      final reminders = body['reminders'] ?? 0;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Синхронизация завершена: стартов $started, завершений $finished, напоминаний $reminders',
          ),
          backgroundColor: const Color(0xFF27AE60),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось синхронизировать статусы: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startNearestTournament() async {
    final upcoming = ref.read(tournamentProvider).where((t) => t.effectiveStatus == 'upcoming').toList();
    if (upcoming.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет предстоящих турниров для ручного запуска')),
      );
      return;
    }

    final next = upcoming.reduce((a, b) => a.startDate.isBefore(b.startDate) ? a : b);

    try {
      await ApiService().post('/tournaments/${next.id}/start');
      await ref.read(tournamentProvider.notifier).load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Турнир "${next.name}" запущен вручную')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось запустить турнир: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showBulkNotificationDialog() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String? selectedTournamentId;
    final tournaments = ref.read(tournamentProvider);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xff1D232C),
              title: const Text('Рассылка уведомлений'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedTournamentId,
                      decoration: const InputDecoration(
                        labelText: 'Турнир (необязательно)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Всем пользователям'),
                        ),
                        ...tournaments.map((t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(t.name),
                        )),
                      ],
                      onChanged: (value) => setState(() => selectedTournamentId = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Заголовок',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: messageController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Сообщение',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final message = messageController.text.trim();
                    if (title.isEmpty || message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните заголовок и сообщение')),
                      );
                      return;
                    }

                    try {
                      await ApiService().post('/notifications/broadcast', data: {
                        'title': title,
                        'message': message,
                        if (selectedTournamentId != null) 'tournament_id': selectedTournamentId,
                      });
                      if (!mounted) return;
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Уведомления отправлены')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка отправки: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Отправить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatsSection(
    List<Tournament> tournaments,
    TournamentStats stats,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              title: 'Всего турниров',
              value: '${stats.total}',
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFF1ABC9C),
            ),
            _buildStatCard(
              title: 'Предстоящие',
              value: '${stats.upcoming}',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF3498DB),
            ),
            _buildStatCard(
              title: 'Активные',
              value: '${stats.inProgress}',
              icon: Icons.play_circle_rounded,
              color: const Color(0xFFE67E22),
            ),
            _buildStatCard(
              title: 'Завершены',
              value: '${stats.completed}',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF95A5A6),
            ),
          ].map((entry) {
            if (isNarrow) {
              return SizedBox(
                width: constraints.maxWidth,
                child: entry,
              );
            }
            return SizedBox(
              width: (constraints.maxWidth - 36) / 4,
              child: entry,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSearchAndFiltersSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: isNarrow ? constraints.maxWidth : constraints.maxWidth - 220,
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
            Container(
              width: isNarrow ? constraints.maxWidth : 180,
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
            SizedBox(
              width: isNarrow ? constraints.maxWidth : 220,
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
      },
    );
  }

  List<Widget> _buildTournamentsList(List<Tournament> tournaments) {
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
      filtered = filtered
          .where((t) => t.effectiveStatus == filterStatus)
          .toList();
    }

    if (filtered.isEmpty) {
      return [
        Container(
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
        ),
      ];
    }

    return filtered.map((tournament) {
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
    }).toList();
  }
}
