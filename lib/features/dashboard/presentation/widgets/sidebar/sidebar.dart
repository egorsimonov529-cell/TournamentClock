import 'package:flutter/material.dart';

import 'sidebar_item.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onMenuChange;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onMenuChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .03),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: .05),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Poker Club ERM",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          ..._menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return SidebarItem(
              icon: item.icon,
              title: item.title,
              selected: selectedIndex == index,
              onTap: () {
                onMenuChange(index);
              },
            );
          }),

          const Spacer(),

          const Divider(
            color: Color(0xFF2A2D35),
          ),

          const SizedBox(height: 18),

          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            ),
            title: Text(
              "Administrator",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Super Admin",
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  static const List<_MenuItem> _menuItems = [
    _MenuItem(
      icon: Icons.dashboard_rounded,
      title: "Dashboard",
    ),
    _MenuItem(
      icon: Icons.people_alt_rounded,
      title: "Игроки",
    ),
    _MenuItem(
      icon: Icons.emoji_events_rounded,
      title: "Турниры",
    ),
    _MenuItem(
      icon: Icons.payments_rounded,
      title: "Финансы",
    ),
    _MenuItem(
      icon: Icons.card_giftcard_rounded,
      title: "Лояльность",
    ),
    _MenuItem(
      icon: Icons.settings_rounded,
      title: "Настройки",
    ),
    _MenuItem(
      icon: Icons.timer_rounded,
      title: "Tournament Clock",
    ),
  ];
}

class _MenuItem {
  final IconData icon;
  final String title;

  const _MenuItem({
    required this.icon,
    required this.title,
  });
}
