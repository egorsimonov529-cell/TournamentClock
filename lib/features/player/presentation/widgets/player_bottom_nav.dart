import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Постоянная нижняя навигация Player App
class PlayerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PlayerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildItem(Icons.home_rounded, 'Главная', 0),
          _buildItem(Icons.emoji_events_rounded, 'Турниры', 1),
          _buildItem(Icons.account_balance_wallet_rounded, 'Касса', 2),
          _buildItem(Icons.person_rounded, 'Профиль', 3),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
