import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/domain/providers/auth_state_provider.dart';
import '../../../domain/admin_workspace_state.dart';
import 'sidebar_item.dart';

class Sidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onMenuChange;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onMenuChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final workspace = ref.watch(adminWorkspaceProvider);
    final clubName = workspace.clubName.trim().isNotEmpty
        ? workspace.clubName
        : 'Poker Club ERM';
    final login = user?.login;
    final initial = login != null && login.isNotEmpty
        ? login[0].toUpperCase()
        : '?';
    final role = user?.role == 'admin'
        ? 'Super Admin'
        : (user?.role ?? 'Admin');

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clubName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._menuItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SidebarItem(
                      icon: item.icon,
                      title: item.title,
                      selected: selectedIndex == index,
                      onTap: () => onMenuChange(index),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2D35)),
          const SizedBox(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(radius: 20, child: Text(initial)),
            title: Text(
              login ?? 'Administrator',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(role, style: const TextStyle(color: Colors.white54)),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => ref.read(authStateProvider.notifier).logout(),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Выйти',
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
    _MenuItem(icon: Icons.dashboard_rounded, title: 'Dashboard'),
    _MenuItem(icon: Icons.people_alt_rounded, title: 'Игроки'),
    _MenuItem(icon: Icons.military_tech_rounded, title: 'Ранги'),
    _MenuItem(icon: Icons.emoji_events_rounded, title: 'Турниры'),
    _MenuItem(icon: Icons.payments_rounded, title: 'Финансы'),
    _MenuItem(icon: Icons.card_giftcard_rounded, title: 'Лояльность'),
    _MenuItem(icon: Icons.article_rounded, title: 'Новости'),
    _MenuItem(icon: Icons.emoji_events_rounded, title: 'Достижения'),
    _MenuItem(icon: Icons.settings_rounded, title: 'Настройки'),
    _MenuItem(icon: Icons.timer_rounded, title: 'Tournament Clock'),
  ];
}

class _MenuItem {
  final IconData icon;
  final String title;

  const _MenuItem({required this.icon, required this.title});
}

