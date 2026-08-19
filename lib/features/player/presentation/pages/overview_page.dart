import 'package:flutter/material.dart';

import '../../domain/models/player_model.dart';
import '../widgets/stats_overview.dart';
import '../widgets/quick_actions.dart';
import '../widgets/upcoming_tournaments.dart';

class OverviewPage extends StatelessWidget {
  final PlayerProfile player;

  const OverviewPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          StatsOverview(player: player),
          QuickActions(),
          SizedBox(height: 16),
          UpcomingTournaments(),
        ],
      ),
    );
  }
}
