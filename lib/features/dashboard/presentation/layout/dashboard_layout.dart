import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/app_window.dart';
import '../../../achievements/presentation/screens/admin_achievements_screen.dart';
import '../../../players/domain/models/admin_player.dart';
import '../../../players/domain/providers/admin_players_provider.dart';
import '../../../players/presentation/screens/admin_players_screen.dart';
import '../../../players/presentation/screens/admin_ranks_screen.dart';
import '../../../tournament/domain/models/tournament_model.dart';
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
  bool _showSidebar = false;

  final List<String> _menuTitles = const [
    "Dashboard",
    "Игроки",
    "Ранги",
    "Турниры",
    "Финансы",
    "Лояльность",
    "Новости",
    "Достижения",
    "Часы",
    "Настройки",
  ];

  // Кэш для TournamentListScreen чтобы он не пересоздавался
  final GlobalKey _tournamentListKey = GlobalKey();

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  void _selectMenu(int index) {
    setState(() {
      _selectedMenuIndex = index;
      _showSidebar = false;
    });
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Text(
        'Доступ запрещён',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  Widget _buildSelectedContent({
    required bool isMobile,
    required bool isAdmin,
    required List<Tournament> tournaments,
    required TournamentStats stats,
    required List<AdminPlayer> players,
  }) {
    if (_selectedMenuIndex == 3) {
      return TournamentListScreen(key: _tournamentListKey);
    }

    if (_selectedMenuIndex == 1) {
      return isAdmin ? const AdminPlayersScreen() : _buildAccessDenied();
    }

    if (_selectedMenuIndex == 2) {
      return isAdmin ? const AdminRanksScreen() : _buildAccessDenied();
    }

    if (_selectedMenuIndex == 4) {
      return isAdmin ? const AdminFinanceScreen() : _buildAccessDenied();
    }

    if (_selectedMenuIndex == 5) {
      return isAdmin ? const AdminLoyaltyScreen() : _buildAccessDenied();
    }

    if (_selectedMenuIndex == 6) {
      return isAdmin ? const AdminNewsScreen() : _buildAccessDenied();
    }

    if (_selectedMenuIndex == 7) {
      return isAdmin ? const AdminAchievementsScreen() : _buildAccessDenied();
    }

    if (_selectedMenuIndex == 8) {
      return isAdmin ? const TournamentClockScreen() : _buildAccessDenied();
    }

    if (_selectedMenuIndex == 9) {
      return isAdmin ? const AdminSettingsScreen() : _buildAccessDenied();
    }

    if (_selectedMenuIndex == 0) {
      if (isMobile) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
                child: StatCard(
                  title: "Всего игроков",
                  value: "${players.length}",
                  icon: Icons.people_alt_rounded,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: StatCard(
                  title: "Всего турниров",
                  value: "${stats.total}",
                  icon: Icons.emoji_events_rounded,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: StatCard(
                  title: "Предстоящие",
                  value: "${stats.upcoming}",
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: StatCard(
                  title: "Активные",
                  value: "${stats.inProgress}",
                  icon: Icons.play_circle_rounded,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (tournaments.isEmpty)
                      const Center(
                        child: Text(
                          "Турниров пока нет",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tournaments.take(5).length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: Color(0xff2A2D35)),
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
                    const SizedBox(height: 18),
                    const Text(
                      'Новости клуба',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(height: 220, child: PostsFeed()),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "Всего игроков",
                  value: "${players.length}",
                  icon: Icons.people_alt_rounded,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: StatCard(
                  title: "Всего турниров",
                  value: "${stats.total}",
                  icon: Icons.emoji_events_rounded,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: StatCard(
                  title: "Предстоящие",
                  value: "${stats.upcoming}",
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: StatCard(
                  title: "Активные",
                  value: "${stats.inProgress}",
                  icon: Icons.play_circle_rounded,
                ),
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
                  if (tournaments.isEmpty)
                    const Center(
                      child: Text(
                        "Турниров пока нет",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: tournaments.take(5).length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: Color(0xff2A2D35)),
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
                  const Text(
                    'Новости клуба',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: PostsFeed()),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    final contentPadding = isMobile ? 14.0 : 36.0;
    final tournaments = ref.watch(tournamentProvider);
    final players = ref.watch(adminPlayersProvider).players;
    final stats = ref.read(tournamentProvider.notifier).getStats();
    final user = ref.watch(authStateProvider).user;
    final userRole = (user?.role ?? '').trim().toLowerCase();
    final isAdmin = const {'admin', 'super_admin', 'superadmin', 'administrator'}
        .contains(userRole);

    return AppWindow(
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  if (!isMobile)
                    SizedBox(
                      width: 280,
                      child: Sidebar(
                        onMenuChange: _selectMenu,
                        selectedIndex: _selectedMenuIndex,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(contentPadding),
                      child: Column(
                        children: [
                          TopBar(
                            sectionTitle: _menuTitles[_selectedMenuIndex],
                            onMenuTap: isMobile ? _toggleSidebar : null,
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: _buildSelectedContent(
                              isMobile: isMobile,
                              isAdmin: isAdmin,
                              tournaments: tournaments,
                              stats: stats,
                              players: players,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isMobile && _showSidebar)
              Positioned.fill(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Row(
                    children: [
                      Container(
                        width: 280,
                        color: const Color(0xff121317),
                        child: Sidebar(
                          onMenuChange: _selectMenu,
                          selectedIndex: _selectedMenuIndex,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleSidebar,
                          child: Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
