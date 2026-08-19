import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/achievement_card.dart';
import '../widgets/screen_widgets.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  String _filter = "Все";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(child: ScreenTitle(title: "Мои достижения")),

          // Filters
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  FilterChipWidget(label: "Все", selected: true),
                  SizedBox(width: AppSpacing.sm),
                  FilterChipWidget(label: "Полученные"),
                  SizedBox(width: AppSpacing.sm),
                  FilterChipWidget(label: "Недоступные"),
                ],
              ),
            ),
          ),

          // Achievements list
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: AchievementCard(
                  title: "Первый турнир",
                  description: "Примите участие в первом турнире",
                  icon: Icons.emoji_events_rounded,
                  progress: 1,
                  required: 1,
                  achieved: true,
                  accentColor: AppColors.gold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: AchievementCard(
                  title: "Регуляр",
                  description: "Участвуйте в 10 турнирах",
                  icon: Icons.schedule_rounded,
                  progress: 7,
                  required: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: AchievementCard(
                  title: "Победитель",
                  description: "Займите 1 место в турнире",
                  icon: Icons.workspace_premium_rounded,
                  progress: 0,
                  required: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: AchievementCard(
                  title: "Крупный выигрыш",
                  description: "Выиграйте 50 000 ₽ в одном турнире",
                  icon: Icons.trending_up_rounded,
                  progress: 35000,
                  required: 50000,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: AchievementCard(
                  title: "Ночной игрок",
                  description: "Участвуйте в турнирах после 23:00",
                  icon: Icons.nightlight_rounded,
                  progress: 3,
                  required: 5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: AchievementCard(
                  title: "High Roller",
                  description: "Проиграйте 100 000 ₽ в турнирах",
                  icon: Icons.diamond_rounded,
                  progress: 67000,
                  required: 100000,
                ),
              ),
            ]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
