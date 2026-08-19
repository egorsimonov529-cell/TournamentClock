import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/tournament_list_item.dart';
import '../widgets/section_header.dart';

/// Dashboard игрока — главный экран
class PlayerDashboardPage extends StatelessWidget {
  const PlayerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),

          // Balance
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          const SliverToBoxAdapter(
            child: BalanceCard(
              label: "Баланс",
              amount: "25 000 ₽",
              showDetails: true,
            ),
          ),

          // Bonuses
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          const SliverToBoxAdapter(
            child: BalanceCard(
              label: "Бонусы",
              amount: "5 000 ₽",
              icon: Icons.local_offer_rounded,
              accentColor: AppColors.gold,
            ),
          ),

          // Quick actions
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(
            child: SectionHeader(title: "Быстрые действия"),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.person_rounded,
                      title: "Мой профиль",
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.emoji_events_rounded,
                      title: "Мои турниры",
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: SizedBox(
                width: double.infinity,
                child: QuickActionButton(
                  icon: Icons.account_balance_wallet_rounded,
                  title: "Касса",
                  onTap: () {},
                ),
              ),
            ),
          ),

          // Promo banner
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(
            child: PromoBanner(
              title: "POKER NIGHT",
              subtitle: "Еженедельный турнир с гарантированным призовым фондом",
              cta: "Участвовать",
            ),
          ),

          // Upcoming tournaments
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(
            child: SectionHeader(title: "Ближайшие турниры"),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TournamentListItem(
                  name: "Night Deepstack",
                  date: "15 авг",
                  time: "21:00",
                  buyIn: "2 000 ₽",
                  prizePool: "150 000 ₽",
                  status: "Регистрация",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TournamentListItem(
                  name: "Sunday Special",
                  date: "17 авг",
                  time: "18:00",
                  buyIn: "1 000 ₽",
                  prizePool: "75 000 ₽",
                  status: "Скоро",
                ),
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff151921),
        border: Border(
          bottom: BorderSide(color: const Color(0xff252C28), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Иван Петров",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  "VIP Silver",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
