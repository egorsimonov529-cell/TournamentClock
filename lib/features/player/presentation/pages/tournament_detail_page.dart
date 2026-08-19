import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/screen_widgets.dart';

class TournamentDetailPage extends StatelessWidget {
  final String tournamentId;

  const TournamentDetailPage({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: ScreenTitle(title: "Night Deepstack"),
          ),

          // Info header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "15 августа 2026",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Начало: 21:00",
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.card),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Бай-ин",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "2 000 ₽",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Key info
          const SliverToBoxAdapter(child: SectionHeader(title: "Информация")),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: AppCard(
                child: Column(
                  children: [
                    _buildInfoRow(
                      "Призовой фонд",
                      "150 000 ₽",
                      Icons.emoji_events_rounded,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      "Стартовый стек",
                      "10 000 очков",
                      Icons.casino_rounded,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow("Уровни", "15 минут", Icons.timer_rounded),
                    const Divider(height: 24),
                    _buildInfoRow(
                      "Поздняя рег.",
                      "до 22:00",
                      Icons.access_time_rounded,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow("Re-entry", "Да", Icons.refresh_rounded),
                    const Divider(height: 24),
                    _buildInfoRow(
                      "Add-on",
                      "Доступен",
                      Icons.add_circle_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Row(
                children: [
                  Expanded(child: _Tab(label: "О турнире", selected: true)),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: _Tab(label: "Структура")),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: _Tab(label: "Игроки")),
                ],
              ),
            ),
          ),

          // Tab content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardLg),
              child: const Text(
                "Deepstack турнир с замедленной структурой. Поздняя регистрация до 22:00. Re-entry разрешен. Add-on после 2-го уровня.",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),

          // Register button
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: PrimaryButton(label: "Зарегистрироваться"),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  const _Tab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
    );
  }
}
