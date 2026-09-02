import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/domain/providers/auth_state_provider.dart';

class TopBar extends ConsumerStatefulWidget {
  final String sectionTitle;

  const TopBar({super.key, this.sectionTitle = 'Dashboard'});

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

    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Добро пожаловать, $login! 👋',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                widget.sectionTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 320,
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
          const SizedBox(width: 20),
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
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(initial)
                : null,
          ),
        ],
      ),
    );
  }
}
