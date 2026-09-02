import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tournament_clock/core/ui/ios/ios_card.dart';
import '../../domain/models/player_model.dart';
import '../../../../core/models/rps_rank.dart';

class IosProfilePage extends StatelessWidget {
  final PlayerProfile player;

  const IosProfilePage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = player.avatarUrl != null && player.avatarUrl!.isNotEmpty;
    final displayName = player.firstName?.isNotEmpty == true
      ? player.firstName!
      : (player.lastName?.isNotEmpty == true ? player.lastName! : player.login);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(displayName)),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            IosCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: hasAvatar ? NetworkImage(player.avatarUrl!) : null,
                    backgroundColor: Colors.white12,
                    child: hasAvatar ? null : Text(player.login.isNotEmpty ? player.login[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('RPS ${player.rpsRank.label}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(player.rankPoints > 0 ? '${player.rankPoints} rating' : '—', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IosCard(
              child: Column(
                children: [
                  ListTile(leading: const Icon(CupertinoIcons.person), title: const Text('Изменить профиль', style: TextStyle(color: Colors.white)), trailing: const Icon(CupertinoIcons.right_chevron)),
                  const Divider(color: Colors.white12),
                  ListTile(leading: const Icon(CupertinoIcons.lock), title: const Text('Изменить пароль', style: TextStyle(color: Colors.white)), trailing: const Icon(CupertinoIcons.right_chevron)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
