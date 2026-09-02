import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_model.dart';
import '../widgets/stats_overview.dart';
import '../widgets/quick_actions.dart';
import '../widgets/upcoming_tournaments.dart';

class OverviewPage extends StatelessWidget {
  final PlayerProfile player;
  final VoidCallback onOpenTournaments;
  final VoidCallback onOpenLeaderboard;

  const OverviewPage({
    super.key,
    required this.player,
    required this.onOpenTournaments,
    required this.onOpenLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 700;
    final isIOS = Platform.isIOS;
    final horizontalPadding = isPhone ? 14.0 : 32.0;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: isPhone ? 16 : 24),
      child: Column(
        children: [
          _GreetingBanner(
            player: player,
            horizontalPadding: horizontalPadding,
            isIOS: isIOS,
          ),
          const SizedBox(height: 8),
          StatsOverview(player: player),
          const SizedBox(height: 8),
          QuickActions(
            onOpenTournaments: onOpenTournaments,
            onOpenLeaderboard: onOpenLeaderboard,
          ),
          const SizedBox(height: 16),
          UpcomingTournaments(onOpenTournaments: onOpenTournaments),
        ],
      ),
    );
  }
}

class _GreetingBanner extends StatelessWidget {
  final PlayerProfile player;
  final double horizontalPadding;
  final bool isIOS;

  const _GreetingBanner({
    required this.player,
    required this.horizontalPadding,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    final name = player.firstName ?? player.lastName ?? player.login;
    final subtitle = player.email;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        18,
        horizontalPadding,
        12,
      ),
            child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.22),
              const Color(0xff111821),
            ],
          ),
          borderRadius: BorderRadius.circular(isIOS ? 24 : 18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.24),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(isIOS ? 18 : 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
                     child: Icon(
                       CupertinoIcons.hand_raised,
                       color: AppColors.primary,
                       size: 27,
                     ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Добро пожаловать, $name!',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700).merge(const TextStyle(color: AppColors.white)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.5, color: AppColors.white.withValues(alpha: 0.6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
