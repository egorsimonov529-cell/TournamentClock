import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class UpcomingTournaments extends StatelessWidget {
  const UpcomingTournaments({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ближайшие турниры",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Все турниры",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTournamentItem(
            name: "Sunday Mega Tournament",
            date: "10 авг, 20:00",
            buyIn: "₽1,000",
            prizePool: "₽500,000",
            spots: "45/100",
          ),
          const SizedBox(height: 12),
          _buildTournamentItem(
            name: "Weekly Championship",
            date: "12 авг, 19:00",
            buyIn: "₽5,000",
            prizePool: "₽250,000",
            spots: "78/150",
          ),
          const SizedBox(height: 12),
          _buildTournamentItem(
            name: "Beginner's Cup",
            date: "15 авг, 18:00",
            buyIn: "₽500",
            prizePool: "₽50,000",
            spots: "23/50",
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTournamentItem({
    required String name,
    required String date,
    required String buyIn,
    required String prizePool,
    required String spots,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xff2A2D35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          _buildMiniInfo("Buy-in", buyIn),
          const SizedBox(width: 24),
          _buildMiniInfo("Приз.", prizePool),
          const SizedBox(width: 24),
          _buildMiniInfo("Места", spots),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Join",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
