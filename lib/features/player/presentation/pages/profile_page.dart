import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/section_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardLg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    "Иван Петров",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      "VIP Silver • ID: #12847",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Edit button
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: GhostButton(label: "Редактировать профиль"),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Menu items
          const SliverToBoxAdapter(child: SectionHeader(title: "Аккаунт")),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildMenuItem(
                context,
                Icons.person_outline_rounded,
                "Личные данные",
              ),
              _buildMenuItem(
                context,
                Icons.history_rounded,
                "История посещений",
              ),
              _buildMenuItem(
                context,
                Icons.emoji_events_rounded,
                "Мои достижения",
              ),
              _buildMenuItem(
                context,
                Icons.workspace_premium_rounded,
                "Уровень лояльности",
                onTap: () => context.push('/loyalty'),
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          const SliverToBoxAdapter(child: SectionHeader(title: "Настройки")),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildMenuItem(
                context,
                Icons.notifications_outlined,
                "Уведомления",
                onTap: () => context.push('/notifications'),
              ),
              _buildMenuItem(context, Icons.security_rounded, "Безопасность"),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Logout
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: PrimaryButton(label: "Выйти из аккаунта", outlined: true),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: 4,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.card),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
