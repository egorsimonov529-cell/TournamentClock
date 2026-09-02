import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_model.dart';

class PlayerHeader extends ConsumerWidget {
  final PlayerProfile player;

  const PlayerHeader({super.key, required this.player});

  String _displayName(PlayerProfile p) => p.firstName?.isNotEmpty == true
      ? p.firstName!
      : p.lastName?.isNotEmpty == true
      ? p.lastName!
      : p.login;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final name = _displayName(player);
    final hasAvatar = player.avatarUrl != null && player.avatarUrl!.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 26,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isIOS ? const Color(0xff121A22) : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.24),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Личный кабинет',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .6),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Добро пожаловать, $name!',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            _badge('RPS ${player.rpsRank.label}', Icons.military_tech_rounded),
            const SizedBox(width: 12),
            _badge(player.rankPoints > 0 ? '${player.rankPoints} rating' : '—', Icons.insights_rounded),
            const SizedBox(width: 16),
          ],
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: .2),
            backgroundImage: hasAvatar ? NetworkImage(player.avatarUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xff12171A).withOpacity(0.28),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.primary.withValues(alpha: .36)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
