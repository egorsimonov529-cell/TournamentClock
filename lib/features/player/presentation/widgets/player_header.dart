import 'package:flutter/material.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_model.dart';

class PlayerHeader extends StatelessWidget {
  final PlayerProfile player;

  const PlayerHeader({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 32,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff151921),
        border: Border(bottom: BorderSide(color: Color(0xff2A2D35))),
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
                    color: Colors.white.withOpacity(.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Добро пожаловать, ${player.login}!',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            _badge('RPS ${player.rpsRank.label}', Icons.military_tech_rounded),
            const SizedBox(width: 12),
            _badge('${player.rankPoints} rating', Icons.insights_rounded),
            const SizedBox(width: 16),
          ],
          CircleAvatar(
            radius: 23,
            backgroundColor: AppColors.primary.withOpacity(.2),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(.3),
          AppColors.primary.withOpacity(.08),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withOpacity(.45)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.warning, size: 17),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
