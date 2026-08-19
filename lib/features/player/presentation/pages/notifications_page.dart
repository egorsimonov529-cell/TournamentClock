import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/notification_card.dart';
import '../widgets/screen_widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: ScreenTitle(
              title: "Уведомления",
              actions: [
                Icon(Icons.done_all_rounded, size: 24, color: AppColors.accent),
              ],
            ),
          ),

          // Today
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.pageHorizontal,
                right: AppSpacing.pageHorizontal,
                top: AppSpacing.md,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                "Сегодня",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: NotificationCard(
                title: "Турнир Night Deepstack",
                description: "Регистрация открыта до 21:00",
                time: "14:30",
                icon: Icons.emoji_events_rounded,
                isRead: false,
                iconColor: AppColors.gold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: NotificationCard(
                title: "Пополнение баланса",
                description: "5 000 ₽ успешно зачислены",
                time: "14:32",
                icon: Icons.account_balance_wallet_rounded,
                isRead: false,
                iconColor: AppColors.accent,
              ),
            ),
          ),

          // Yesterday
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.pageHorizontal,
                right: AppSpacing.pageHorizontal,
                top: AppSpacing.lg,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                "Вчера",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: NotificationCard(
                title: "Бонус активирован",
                description: "Welcome Bonus +5 000 ₽",
                time: "09:00",
                icon: Icons.local_offer_rounded,
                iconColor: AppColors.gold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: NotificationCard(
                title: "Напоминание",
                description: "Завтра Sunday Special в 18:00",
                time: "18:00",
                icon: Icons.notification_important_rounded,
                iconColor: AppColors.warning,
              ),
            ),
          ),

          // Earlier
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.pageHorizontal,
                right: AppSpacing.pageHorizontal,
                top: AppSpacing.lg,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                "Ранее",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: NotificationCard(
                title: "Вывод средств",
                description: "3 000 ₽ обрабатываются",
                time: "13 авг",
                icon: Icons.swap_horiz_rounded,
                iconColor: AppColors.info,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
