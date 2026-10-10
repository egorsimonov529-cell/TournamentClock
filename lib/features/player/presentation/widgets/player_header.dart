import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/club_logo.dart';
import '../../../dashboard/domain/admin_workspace_state.dart';
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
    final compact = MediaQuery.sizeOf(context).width < 420;
    final name = _displayName(player);
    final hasAvatar = player.avatarUrl != null && player.avatarUrl!.isNotEmpty;
    final workspace = ref.watch(adminWorkspaceProvider);
    final clubName = workspace.clubName.trim().isNotEmpty ? workspace.clubName : 'Poker Club';
    final logoUrl = workspace.logoUrl.trim().isNotEmpty ? workspace.logoUrl : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Color(0xff1F2A31), width: 1),
        ),
      ),
      child: Row(
        children: [
          ClubLogo(
            logoUrl: logoUrl,
            size: compact ? 38 : 44,
            borderRadius: 12,
            borderWidth: 1,
            borderColor: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  workspace.city != null && workspace.city!.trim().isNotEmpty
                      ? 'Покер не на деньги • ${workspace.city}'
                      : 'Покер не на деньги',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.push('/about'),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.18), width: 1),
              ),
              child: Text(
                'О клубе',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: compact ? 17 : 19,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: hasAvatar ? NetworkImage(player.avatarUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
