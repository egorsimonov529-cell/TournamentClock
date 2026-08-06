import 'package:flutter/material.dart';

import '../widgets/stats_overview.dart';
import '../widgets/quick_actions.dart';
import '../widgets/upcoming_tournaments.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        StatsOverview(),
        QuickActions(),
        SizedBox(height: 16),
        UpcomingTournaments(),
      ],
    );
  }
}
