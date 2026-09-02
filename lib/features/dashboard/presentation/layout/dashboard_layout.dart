import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/app_window.dart';
import '../../../achievements/presentation/screens/admin_achievements_screen.dart';
import '../../../players/domain/providers/admin_players_provider.dart';
import '../../../players/presentation/screens/admin_players_screen.dart';
import '../../../players/presentation/screens/admin_ranks_screen.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../../../tournament/presentation/screens/tournament_list_screen.dart';
import '../../../tournament_clock/presentation/screens/tournament_clock_screen.dart';
import '../screens/admin_finance_screen.dart';
import '../screens/admin_loyalty_screen.dart';
import '../screens/admin_settings_screen.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../news/presentation/screens/admin_news_screen.dart';
import '../../../news/presentation/widgets/posts_feed.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/stat_card/stat_card.dart';
import '../widgets/topbar/top_bar.dart';

class DashboardLayout extends ConsumerStatefulWidget {
  const DashboardLayout({super.key});

  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout> {
  int _selectedMenuIndex = 0;

  final List<String> _menuTitles = const [
    "Dashboard",
    "Игроки",
    "Ранги",
    "Турниры",
    "Финансы",
    "Лояльность",
    "Новости",
    "Достижения",
    "Настройки",
    "Tournament Clock",
  ];

  // Кэш для TournamentListScreen чтобы он не пересоздавался
  final GlobalKey _tournamentListKey = GlobalKey();

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentProvider);
    final players = ref.watch(adminPlayersProvider).players;
    final stats = ref.read(tournamentProvider.notifier).getStats();
    final user = ref.watch(authStateProvider).user;
    final isAdmin = user?.role == 'admin';

    return AppWindow(
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: Sidebar(
              onMenuChange: (index) {
                setState(() {
                  _selectedMenuIndex = index;
                });
              },
              selectedIndex: _selectedMenuIndex,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                children: [
                  TopBar(sectionTitle: _menuTitles[_selectedMenuIndex]),

                  const SizedBox(height: 30),

                  if (_selectedMenuIndex == 9) ...[
                    // Tournament Clock
                    Expanded(
                      child: SingleChildScrollView(
                        child: TournamentClockScreen(
                          key: const Key('clock_screen'),
                        ),
                      ),
                    ),
                  ] else if (_selectedMenuIndex == 3) ...[
                    // Турниры
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Expanded(
                          child: TournamentListScreen(key: _tournamentListKey),
                        );
                      },
                    ),
                  ] else if (_selectedMenuIndex == 1) ...[
                    if (isAdmin) const Expanded(child: AdminPlayersScreen()) else Expanded(child: Center(child: Text('Доступ запрещён', style: TextStyle(color: Colors.white54)))),
                  ] else if (_selectedMenuIndex == 2) ...[
                    if (isAdmin) const Expanded(child: AdminRanksScreen()) else Expanded(child: Center(child: Text('Доступ запрещён', style: TextStyle(color: Colors.white54)))),
                  ] else if (_selectedMenuIndex == 0) ...[
                    Row(
                      children: [
                        StatCard(
                          title: "Всего игроков",
                          value: "${players.length}",
                          icon: Icons.people_alt_rounded,
                        ),

                        const SizedBox(width: 18),

                        StatCard(
                          title: "Всего турниров",
                          value: "${stats.total}",
                          icon: Icons.emoji_events_rounded,
                        ),

                        const SizedBox(width: 18),

                        StatCard(
                          title: "Предстоящие",
                          value: "${stats.upcoming}",
                          icon: Icons.calendar_today_rounded,
                        ),

                        const SizedBox(width: 18),

                        StatCard(
                          title: "Активные",
                          value: "${stats.inProgress}",
                          icon: Icons.play_circle_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xff191D24),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Последние турниры",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: tournaments.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "Турниров пока нет",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: tournaments.take(5).length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                            color: Color(0xff2A2D35),
                                          ),
                                      itemBuilder: (context, index) {
                                        final tournament = tournaments[index];
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            tournament.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${tournament.statusDisplay} • '
                                            '${tournament.currentPlayers}/${tournament.maxPlayers} игроков',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                            ),
                                          ),
                                          trailing: Text(
                                            _formatDate(tournament.startDate),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 18),
                            const Text('Новости клуба', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Expanded(child: PostsFeed()),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_selectedMenuIndex == 4) ...[
                    if (isAdmin) const Expanded(child: AdminFinanceScreen()) else Expanded(child: Center(child: Text('Доступ запрещён', style: TextStyle(color: Colors.white54)))),
                  ] else if (_selectedMenuIndex == 5) ...[
                    if (isAdmin) const Expanded(child: AdminLoyaltyScreen()) else Expanded(child: Center(child: Text('Доступ запрещён', style: TextStyle(color: Colors.white54)))),
                  ] else if (_selectedMenuIndex == 6) ...[
                    // Новости
                    if (isAdmin) const Expanded(child: AdminNewsScreen()) else Expanded(child: Center(child: Text('Доступ запрещён', style: TextStyle(color: Colors.white54)))),
                  ] else if (_selectedMenuIndex == 7) ...[
                    if (isAdmin) const Expanded(child: AdminAchievementsScreen()) else Expanded(child: Center(child: Text('Доступ запрещён', style: TextStyle(color: Colors.white54)))),
                  ] else if (_selectedMenuIndex == 8) ...[
                    if (isAdmin) const Expanded(child: AdminSettingsScreen()) else Expanded(child: Center(child: Text('Доступ запрещён', style: TextStyle(color: Colors.white54)))),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
