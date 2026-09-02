import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;
    final phone = width < 700;
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
              ? Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => _showProfileSettings = false);
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Назад к профилю'),
                        ),
                      ),
                    ),
                    Expanded(child: ProfileSettingsPage(player: widget.player)),
                  ],
                )
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
      body: SafeArea(
        top: false,
        bottom: phone,
        child: phone
            ? Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isIOS
                      ? const Color(0xff121A22)
                      : const Color(0xff111821),
                  borderRadius: BorderRadius.circular(isIOS ? 28 : 20),
                  border: Border.all(
                    color: const Color(0xff10B981).withValues(alpha: 0.28),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 18,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
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
              )
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
      ),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _select,
              backgroundColor: isIOS
                  ? const Color(0xff141D24)
                  : const Color(0xff151921),
              indicatorColor: const Color(0xffD4AF37).withValues(alpha: .18),
              shadowColor: Colors.black.withValues(alpha: 0.2),
              surfaceTintColor: Colors.transparent,
              height: phone ? 64 : 72,
              labelBehavior: width < 430
                  ? NavigationDestinationLabelBehavior.onlyShowSelected
                  : NavigationDestinationLabelBehavior.alwaysShow,
              destinations: items
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.title,
                    ),
                  )
                  .toList(),
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
