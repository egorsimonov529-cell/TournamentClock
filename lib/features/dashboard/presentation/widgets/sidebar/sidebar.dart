import 'package:flutter/material.dart';
import 'package:window_manager_plus/window_manager_plus.dart';

import '../../../../../../core/services/window_manager_service.dart';
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
        color: Colors.white.withOpacity(.03),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(.05),
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
            return Column(
              children: [
                SidebarItem(
                  icon: item.icon,
                  title: item.title,
                  selected: selectedIndex == index,
                  onTap: () {
                    onMenuChange(index);
                  },
                ),
                // Кнопка для Tournament Clock
                if (selectedIndex == 6 && item.title == "Tournament Clock")
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Tooltip(
                      message: 'Открыть таймер в отдельном окне',
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            WindowManagerService.openClockWindow();
                          },
                          icon: const Icon(Icons.window, size: 20),
                          label: const Text('Новое окно'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1ABC9C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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

          const SizedBox(height: 8),

          // Кнопка закрытия окна
          InkWell(
            onTap: () async {
              // Закрываем все дополнительные окна
              await WindowManagerService.closeClockWindow();
              // Закрываем приложение
              await WindowManagerPlus.current.destroy();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Выйти",
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ],
              ),
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
