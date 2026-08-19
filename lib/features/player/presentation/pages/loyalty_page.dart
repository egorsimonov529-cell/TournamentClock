import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/loyalty_card.dart';
import '../widgets/screen_widgets.dart';

class LoyaltyPage extends StatelessWidget {
  const LoyaltyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: ScreenTitle(title: "Уровень лояльности"),
          ),

          // Loyalty level card
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.pageHorizontal),
              child: LoyaltyLevelCard(
                level: "Silver",
                currentPoints: 3200,
                requiredPoints: 10000,
                nextLevel: "Gold",
                nextLevelRequired: 10000,
                levelColor: AppColors.gold,
                benefits: [
                  "Кэшбэк до 5%",
                  "Приоритетная регистрация на турниры",
                  "Персональные бонусы",
                  "Приглашения на закрытые ивенты",
                ],
              ),
            ),
          ),

          // How to earn points
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(
            child: SectionHeader(title: "Как заработать очки?"),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: AppCard(
                child: Column(
                  children: [
                    _buildPointItem(
                      "Участие в турнирах",
                      "+100 очков за каждый бай-ин",
                    ),
                    const Divider(height: 24),
                    _buildPointItem(
                      "Пополнение баланса",
                      "+50 очков за каждые 1000 ₽",
                    ),
                    const Divider(height: 24),
                    _buildPointItem(
                      "Победы в турнирах",
                      "+500 очков за 1 место",
                    ),
                    const Divider(height: 24),
                    _buildPointItem(
                      "Регулярная игра",
                      "+200 бонусных очков в месяц",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Levels preview
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(child: SectionHeader(title: "Уровни")),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Row(
                children: [
                  _buildLevelChip("Bronze", true, AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  _buildLevelChip("Silver", true, AppColors.gold),
                  const SizedBox(width: AppSpacing.sm),
                  _buildLevelChip("Gold", false, AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  _buildLevelChip("Platinum", false, AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  _buildLevelChip("VIP", false, AppColors.error),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPointItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.add_circle_outline_rounded,
          size: 20,
          color: AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelChip(String name, bool achieved, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: achieved ? color.withOpacity(0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: achieved ? color : AppColors.border,
            width: achieved ? 2 : 1,
          ),
        ),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: achieved ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
