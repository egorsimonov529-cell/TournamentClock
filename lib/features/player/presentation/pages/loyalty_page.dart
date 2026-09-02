import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/loyalty_card.dart';
import '../widgets/screen_widgets.dart';
import '../../domain/providers/loyalty_provider.dart';

class LoyaltyPage extends ConsumerWidget {
  const LoyaltyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyaltyAsync = ref.watch(loyaltyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: loyaltyAsync.when(
        data: (data) => CustomScrollView(
          slivers: [
            // Header
            const SliverToBoxAdapter(
              child: ScreenTitle(title: "Уровень лояльности"),
            ),

            // Loyalty level card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                child: LoyaltyLevelCard(
                  level: data.level,
                  currentPoints: data.currentPoints,
                  requiredPoints: data.requiredPoints,
                  nextLevel: data.nextLevel,
                  nextLevelRequired: data.nextLevelRequired,
                  levelColor: AppColors.gold,
                  benefits: data.benefits,
                ),
              ),
            ),

            // Active campaigns
            if (data.campaigns.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              const SliverToBoxAdapter(
                child: SectionHeader(title: "Активные кампании"),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final campaign = data.campaigns[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    campaign.isActive
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: campaign.isActive
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      campaign.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                campaign.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: data.campaigns.length,
                  ),
                ),
              ),
            ],

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Ошибка загрузки: $error'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(loyaltyProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
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
          color: achieved ? color.withValues(alpha: 0.2) : AppColors.card,
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
