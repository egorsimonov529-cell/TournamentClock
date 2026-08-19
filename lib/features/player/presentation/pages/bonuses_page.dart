import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/bonus_card.dart';
import '../widgets/screen_widgets.dart';
import '../widgets/section_header.dart';

class BonusesPage extends StatefulWidget {
  const BonusesPage({super.key});

  @override
  State<BonusesPage> createState() => _BonusesPageState();
}

class _BonusesPageState extends State<BonusesPage> {
  String _tab = "available";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(child: ScreenTitle(title: "Бонусы")),

          // Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _buildTab("Доступные", "available", true),
                  const SizedBox(width: AppSpacing.sm),
                  _buildTab("Активные", "active", false),
                  const SizedBox(width: AppSpacing.sm),
                  _buildTab("История", "history", false),
                ],
              ),
            ),
          ),

          // Bonuses list
          SliverList(
            delegate: SliverChildListDelegate([
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: BonusCard(
                  title: "Welcome Bonus",
                  amount: "5 000 ₽",
                  description: "Бонус за первую регистрацию",
                  validUntil: "20 авг",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: BonusCard(
                  title: "Reload Bonus",
                  amount: "10% до 3 000 ₽",
                  description: "Бонус на пополнение баланса",
                  validUntil: "25 авг",
                  onActivate: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: BonusCard(
                  title: "Tournament Bonus",
                  amount: "1 500 ₽",
                  description: "При регистрации в 3-х турнирах",
                  validUntil: "30 авг",
                  onActivate: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: BonusCard(
                  title: "Birthday Bonus",
                  amount: "2 000 ₽",
                  description: "Персональный бонус в день рождения",
                  validUntil: "1 сен",
                  onActivate: () {},
                ),
              ),
            ]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value, bool selected) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
