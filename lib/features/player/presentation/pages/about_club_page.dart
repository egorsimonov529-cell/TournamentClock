import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/club_logo.dart';
import '../../../dashboard/domain/admin_workspace_state.dart';
import '../widgets/screen_widgets.dart';

class AboutClubPage extends ConsumerWidget {
  const AboutClubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(adminWorkspaceProvider);
    final description = workspace.clubDescription.trim().isNotEmpty
        ? workspace.clubDescription
        : 'Место для честной игры, ярких турниров и сильного сообщества.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: ScreenTitle(title: 'О клубе')),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ClubLogo(
                  logoUrl: workspace.logoUrl.isNotEmpty ? workspace.logoUrl : null,
                  size: 72,
                  borderRadius: 22,
                  borderWidth: 1,
                  borderColor: AppColors.accent,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  workspace.clubName.trim().isNotEmpty ? workspace.clubName : 'Poker Club',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Наша миссия',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: workspace.address?.trim().isNotEmpty == true
                            ? workspace.address!
                            : 'Москва, центр города',
                      ),
                      Divider(height: 24),
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        text: 'Ежедневно с 10:00 до 02:00',
                      ),
                      Divider(height: 24),
                      _InfoRow(
                        icon: Icons.verified_user_outlined,
                        text: 'Ответственная игра и честные правила',
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.accent),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
