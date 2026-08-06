import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/player_header.dart';
import '../pages/overview_page.dart';
import '../pages/tournaments_page.dart';
import '../pages/my_tournaments_page.dart';
import '../pages/balance_page.dart';
import '../pages/profile_settings_page.dart';

class PlayerCabinetLayout extends StatefulWidget {
  final String playerName;
  final String playerLevel;

  const PlayerCabinetLayout({
    super.key,
    this.playerName = "Player",
    this.playerLevel = "1",
  });

  @override
  State<PlayerCabinetLayout> createState() => _PlayerCabinetLayoutState();
}

class _PlayerCabinetLayoutState extends State<PlayerCabinetLayout> {
  int _selectedIndex = 0;

  final List<_MenuItem> _menuItems = [
    _MenuItem(
      icon: Icons.dashboard_rounded,
      title: "Обзор",
      page: () => const OverviewPage(),
    ),
    _MenuItem(
      icon: Icons.emoji_events_rounded,
      title: "Турниры",
      page: () => const TournamentsPage(),
    ),
    _MenuItem(
      icon: Icons.schedule_rounded,
      title: "Мои турниры",
      page: () => const MyTournamentsPage(),
    ),
    _MenuItem(
      icon: Icons.account_balance_wallet_rounded,
      title: "Баланс",
      page: () => const BalancePage(),
    ),
    _MenuItem(
      icon: Icons.person_rounded,
      title: "Настройки",
      page: () => const ProfileSettingsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedPage = _menuItems[_selectedIndex].page;

    return Scaffold(
      backgroundColor: const Color(0xff0F1117),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                PlayerHeader(
                  playerName: widget.playerName,
                  playerLevel: widget.playerLevel,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: selectedPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xff151921),
        border: Border(
          right: BorderSide(
            color: const Color(0xff2A2D35),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.casino_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Poker Club",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ..._menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return SidebarItem(
                icon: item.icon,
                title: item.title,
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            }),
          ],
        ),
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

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.6),
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
