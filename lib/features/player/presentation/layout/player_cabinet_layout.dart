import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_model.dart';
import '../pages/leaderboard_page.dart';
import '../pages/my_seating_page.dart';
import '../pages/my_tournaments_page.dart';
import '../pages/overview_page.dart';
import '../pages/profile_page.dart';
import '../pages/profile_settings_page.dart';
import '../pages/tournaments_page.dart';
import '../pages/ios_profile_page.dart';
import '../pages/ios_tournaments_page.dart';
import '../pages/ios_my_tournaments_page.dart';
import '../pages/ios_my_seating_page.dart';
import '../pages/ios_leaderboard_page.dart';
import '../pages/ios_news_page.dart';
import '../widgets/player_header.dart';
import '../widgets/player_navigation.dart';
import '../../../news/presentation/widgets/posts_feed.dart';

class PlayerCabinetLayout extends StatefulWidget {
  final PlayerProfile player;

  const PlayerCabinetLayout({super.key, required this.player});

  @override
  State<PlayerCabinetLayout> createState() => _PlayerCabinetLayoutState();
}

class _PlayerCabinetLayoutState extends State<PlayerCabinetLayout> {
  int _selectedIndex = 0;
  bool _showProfileSettings = false;

  void _select(int index) {
    if (_selectedIndex == index && (index != 4 || !_showProfileSettings)) {
      return;
    }
    setState(() {
      _selectedIndex = index;
      if (index != 4) _showProfileSettings = false;
    });
  }

  Widget _buildPhoneBody(
    BuildContext context,
    bool isIOS,
    List<_MenuItem> items,
  ) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: isIOS
              ? const Color(0xff121A22)
              : const Color(0xff111821),
        ),
        child: Column(
          children: [
            PlayerHeader(player: widget.player),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: items
                    .map(
                      (item) => KeyedSubtree(
                        key: PageStorageKey(item.title),
                        child: item.page(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 960;
    final phone = width < 560;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final items = () {
      // build menu items with platform-specific page variants
      final useIosPages = isIOS && phone;
      return <_MenuItem>[
        _MenuItem(
          icon: Icons.dashboard_rounded,
          title: 'Обзор',
          page: () => OverviewPage(
            player: widget.player,
            onOpenTournaments: () => _select(1),
            onOpenLeaderboard: () => _select(4),
          ),
        ),
        _MenuItem(
          icon: Icons.emoji_events_rounded,
          title: 'Турниры',
          page: () => useIosPages ? const IosTournamentsPage() : const TournamentsPage(),
        ),
        _MenuItem(
          icon: Icons.schedule_rounded,
          title: 'Мои турниры',
          page: () => useIosPages ? const IosMyTournamentsPage() : const MyTournamentsPage(),
        ),
        _MenuItem(
          icon: Icons.chair_rounded,
          title: 'Рассадка',
          page: () => useIosPages ? const IosMySeatingPage() : const MySeatingPage(),
        ),
        _MenuItem(
          icon: Icons.leaderboard_rounded,
          title: 'Рейтинг',
          page: () => useIosPages ? const IosLeaderboardPage() : const LeaderboardPage(),
        ),
        _MenuItem(
          icon: Icons.person_rounded,
          title: 'Профиль',
          page: () => _showProfileSettings
              ? ProfileSettingsPage(player: widget.player)
              : (useIosPages ? IosProfilePage(player: widget.player) : ProfilePage(
                  player: widget.player,
                  onEditProfile: () {
                    setState(() => _showProfileSettings = true);
                  },
                )),
        ),
        _MenuItem(
          icon: Icons.newspaper_rounded,
          title: 'Новости',
          page: () => useIosPages ? const IosNewsPage() : const PostsFeed(),
        ),
      ];
    }();

    return Scaffold(
      backgroundColor: isIOS
          ? const Color(0xff0E151A)
          : const Color(0xff0F1117),
      body: phone
          ? _buildPhoneBody(context, isIOS, items)
          : Row(
              children: [
                if (desktop)
                  PlayerNavigationRail(
                    items: items
                        .map((item) => PlayerNavigationItem(item.icon, item.title))
                        .toList(),
                    selectedIndex: _selectedIndex,
                    onSelected: _select,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      PlayerHeader(player: widget.player),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: items
                              .map(
                                (item) => KeyedSubtree(
                                  key: PageStorageKey(item.title),
                                  child: item.page(),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: () {
                switch (_selectedIndex) {
                  case 1:
                    return 0;
                  case 4:
                    return 1;
                  case 0:
                  case 2:
                  case 3:
                  case 6:
                    return 2;
                  case 5:
                    return 3;
                  default:
                    return 2;
                }
              }(),
              onDestinationSelected: (index) {
                final mapped = switch (index) {
                  0 => 1,
                  1 => 4,
                  2 => 0,
                  3 => 5,
                  _ => 0,
                };
                _select(mapped);
              },
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primary.withValues(alpha: 0.2),
              shadowColor: Colors.black.withValues(alpha: 0.2),
              surfaceTintColor: Colors.transparent,
              height: phone ? 60 : 72,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.emoji_events_rounded), label: 'Турниры'),
                NavigationDestination(icon: Icon(Icons.leaderboard_rounded), label: 'Рейтинг'),
                NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'Меню'),
                NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
              ],
            ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Widget Function() page;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.page,
  });
}
