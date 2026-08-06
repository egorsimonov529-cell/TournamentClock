import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Ваша статистика",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.emoji_events_rounded,
                title: "Турниров",
                value: "24",
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.verified_rounded,
                title: "Побед",
                value: "3",
                color: AppColors.warning,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.leaderboard_rounded,
                title: "Рейтинг",
                value: "#142",
                color: AppColors.info,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.trending_up_rounded,
                title: "Профит",
               value: "+₽45,200",
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff1D232C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
