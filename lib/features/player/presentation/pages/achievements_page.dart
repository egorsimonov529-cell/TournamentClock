import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../achievements/domain/providers/achievements_providers.dart';
import '../widgets/achievement_card.dart';
import '../widgets/screen_widgets.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: achievementsAsync.when(
        data: (achievements) => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: ScreenTitle(title: 'Мои достижения')),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    FilterChipWidget(label: 'Все', selected: true),
                    SizedBox(width: AppSpacing.sm),
                    FilterChipWidget(label: 'Полученные'),
                    SizedBox(width: AppSpacing.sm),
                    FilterChipWidget(label: 'Недоступные'),
                  ],
                ),
              ),
            ),
            if (achievements.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Нет достижений',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final achievement = achievements[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
                    child: AchievementCard(
                      title: achievement.title,
                      description: achievement.description,
                      icon: achievement.achieved ? Icons.verified_rounded : Icons.lock_outline_rounded,
                      progress: achievement.currentValue,
                      required: achievement.targetValue,
                      achieved: achievement.achieved || achievement.currentValue >= achievement.targetValue,
                      accentColor: AppColors.gold,
                      imageUrl: achievement.imageUrl,
                    ),
                  );
                }, childCount: achievements.length),
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
                onPressed: () => ref.refresh(achievementsListProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
