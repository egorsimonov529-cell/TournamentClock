import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/rps_rank.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 700;
    final compactPhone = width < 420;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final horizontalPadding = compactPhone ? 12.0 : isPhone ? 14.0 : 32.0;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: isPhone ? 16 : 24),
      child: Column(
        children: [
          _GreetingBanner(
            player: player,
            horizontalPadding: horizontalPadding,
            isIOS: isIOS,
          ),
          const SizedBox(height: 10),
          StatsOverview(player: player),
          const SizedBox(height: 12),
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
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'W';
    final rating = player.rpsPoints;
    final rankLabel = player.rpsRank.name.toUpperCase();

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xff1A232A),
              const Color(0xff111821),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.gold.withValues(alpha: 0.5),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          rankLabel,
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '$rating',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'очков',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
