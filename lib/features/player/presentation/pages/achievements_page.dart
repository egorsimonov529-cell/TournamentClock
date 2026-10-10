import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../achievements/domain/providers/achievements_providers.dart';
import '../widgets/achievement_card.dart';
import '../widgets/screen_widgets.dart';

class AchievementsPage extends ConsumerStatefulWidget {
  const AchievementsPage({super.key});

  @override
  ConsumerState<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends ConsumerState<AchievementsPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: achievementsAsync.when(
        data: (achievements) {
          final visibleAchievements = achievements.where((achievement) {
            final completed = achievement.achieved || achievement.currentValue >= achievement.targetValue;
            switch (_filter) {
              case 'received':
                return completed;
              case 'locked':
                return !completed;
              case 'all':
              default:
                return true;
            }
          }).toList();

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: ScreenTitle(title: 'Мои достижения')),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.sm,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      FilterChipWidget(
                        label: 'Все',
                        selected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      FilterChipWidget(
                        label: 'Полученные',
                        selected: _filter == 'received',
                        onTap: () => setState(() => _filter = 'received'),
                      ),
                      FilterChipWidget(
                        label: 'Недоступные',
                        selected: _filter == 'locked',
                        onTap: () => setState(() => _filter = 'locked'),
                      ),
                    ],
                  ),
                ),
              ),
              if (visibleAchievements.isEmpty)
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
                    final achievement = visibleAchievements[index];
                    final completed = achievement.achieved || achievement.currentValue >= achievement.targetValue;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
                      child: AchievementCard(
                        title: achievement.title,
                        description: achievement.description,
                        icon: completed ? Icons.verified_rounded : Icons.lock_outline_rounded,
                        progress: achievement.currentValue,
                        required: achievement.targetValue,
                        achieved: completed,
                        accentColor: AppColors.gold,
                        imageUrl: achievement.imageUrl,
                      ),
                    );
                  }, childCount: visibleAchievements.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
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
