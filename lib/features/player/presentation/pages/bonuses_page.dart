import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/bonus_card.dart';
import '../widgets/screen_widgets.dart';
import '../../domain/providers/bonuses_provider.dart';

class BonusesPage extends ConsumerStatefulWidget {
  const BonusesPage({super.key});

  @override
  ConsumerState<BonusesPage> createState() => _BonusesPageState();
}

class _BonusesPageState extends ConsumerState<BonusesPage> {
  String _tab = "available";

  @override
  Widget build(BuildContext context) {
    final bonusesAsync = ref.watch(bonusesProvider);

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
                  _buildTab("Доступные", "available"),
                  const SizedBox(width: AppSpacing.sm),
                  _buildTab("Активные", "active"),
                  const SizedBox(width: AppSpacing.sm),
                  _buildTab("История", "history"),
                ],
              ),
            ),
          ),

          // Bonuses list
          bonusesAsync.when(
            data: (bonuses) {
              final filteredBonuses = bonuses.where((b) {
                switch (_tab) {
                  case 'active':
                    return b.isActive;
                  case 'history':
                    return false; // Future: filter by user redemption history
                  case 'available':
                  default:
                    return b.isActive;
                }
              }).toList();

              if (filteredBonuses.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'Нет доступных бонусов',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final bonus = filteredBonuses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: BonusCard(
                        title: bonus.title,
                        amount: bonus.value,
                        description: bonus.description.isNotEmpty 
                            ? bonus.description 
                            : bonus.conditions.isNotEmpty 
                                ? bonus.conditions 
                                : null,
                        validUntil: _formatValidUntil(bonus.createdAt),
                        isActive: bonus.isActive,
                        onActivate: bonus.isActive 
                            ? () => _activateBonus(bonus) 
                            : null,
                      ),
                    );
                  },
                  childCount: filteredBonuses.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Ошибка загрузки: $error'),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => ref.refresh(bonusesProvider),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final selected = _tab == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _tab = value);
          ref.read(bonusesProvider.notifier).setTab(value);
        },
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

  String _formatValidUntil(DateTime createdAt) {
    final validUntil = createdAt.add(const Duration(days: 7));
    final months = ['', 'янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final month = months[validUntil.month];
    return '${validUntil.day} $month';
  }

  void _activateBonus(Bonus bonus) {
    // TODO: Implement bonus activation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Бонус "${bonus.title}" активирован!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
