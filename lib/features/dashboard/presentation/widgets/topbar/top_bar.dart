import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/domain/providers/auth_state_provider.dart';

class TopBar extends ConsumerStatefulWidget {
  final String sectionTitle;
  final VoidCallback? onMenuTap;

  const TopBar({super.key, this.sectionTitle = 'Dashboard', this.onMenuTap});

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  bool _hasUnread = true;

  Future<void> _showNotifications() async {
    setState(() => _hasUnread = false);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Уведомления'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.emoji_events_outlined),
              title: Text('Регистрация открыта'),
              subtitle: Text('Night Deepstack начинается в 21:00'),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined),
              title: Text('Баланс пополнен'),
              subtitle: Text('Зачислено 5 000 ₽'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final avatarUrl = user?.avatarUrl?.trim();
    final login = user?.login ?? 'Администратор';
    final initial = login.isNotEmpty ? login[0].toUpperCase() : '?';
    final isCompact = MediaQuery.sizeOf(context).width < 760;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSearch = constraints.maxWidth >= 620;

        return Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: EdgeInsets.symmetric(
            vertical: isCompact ? 10 : 0,
            horizontal: isCompact ? 8 : 0,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onMenuTap != null) ...[
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white),
                      onPressed: widget.onMenuTap,
                    ),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Добро пожаловать, $login! 👋',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.sectionTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 22 : 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showSearch)
                    SizedBox(
                      width: constraints.maxWidth > 900 ? 320 : 180,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Поиск...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xff1D232C),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  if (showSearch) const SizedBox(width: 12),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'Уведомления',
                        onPressed: _showNotifications,
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                      ),
                      if (_hasUnread)
                        const Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            key: ValueKey('unread-indicator'),
                            radius: 4,
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: isCompact ? 16 : 22,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? Text(initial)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
