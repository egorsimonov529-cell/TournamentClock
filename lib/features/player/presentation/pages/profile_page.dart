import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/ios/ios_button.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../../features/auth/domain/providers/auth_state_provider.dart';
import '../../domain/models/player_model.dart';
import '../widgets/section_header.dart';
import 'profile_settings_page.dart';

class ProfilePage extends ConsumerWidget {
  final PlayerProfile player;
  final VoidCallback? onEditProfile;

  const ProfilePage({super.key, required this.player, this.onEditProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullName = '${player.firstName ?? ''} ${player.lastName ?? ''}'
        .trim();
    final displayName = fullName.isNotEmpty ? fullName : player.login;
    final avatarUrl = player.avatarUrl?.trim();
    final fallbackName = player.firstName ?? player.lastName ?? player.login;
    final initial = fallbackName.isNotEmpty
        ? fallbackName[0].toUpperCase()
        : '?';
    final shortId = player.userId.substring(0, min(8, player.userId.length));

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        middle: const Text(
          'Личные данные',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
        ),
        previousPageTitle: 'Назад',
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight.withValues(alpha: 0.2),
                        image: avatarUrl != null && avatarUrl.isNotEmpty
                            ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      player.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Text(
                        '${player.rpsRank.label} • ${player.rpsPoints} RPS • ID: #$shortId',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Аккаунт'),
              const SizedBox(height: 8),
              _buildMenuItem(
                context,
                CupertinoIcons.person,
                'Личные данные',
                onTap: onEditProfile ??
                    () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => ProfileSettingsPage(player: player),
                          ),
                        ),
              ),
              _buildMenuItem(
                context,
                CupertinoIcons.clock,
                'История посещений',
                onTap: () => context.push('/transactions'),
              ),
              _buildMenuItem(
                context,
                CupertinoIcons.star,
                'Мои достижения',
                onTap: () => context.push('/achievements'),
              ),
              _buildMenuItem(
                context,
                CupertinoIcons.star_circle,
                'Уровень лояльности',
                onTap: () => context.push('/loyalty'),
              ),
              const SizedBox(height: 12),
              const SectionHeader(title: 'Настройки'),
              const SizedBox(height: 8),
              _buildMenuItem(
                context,
                CupertinoIcons.bell,
                'Уведомления',
                onTap: () => context.push('/notifications'),
              ),
              _buildMenuItem(
                context,
                CupertinoIcons.lock,
                'Безопасность',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Раздел безопасности скоро будет доступен')),
                  );
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: IosButton(label: 'Выйти из аккаунта', onPressed: () => ref.read(authStateProvider.notifier).logout(), filled: false),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    final item = IosCard(
      padding: const EdgeInsets.all(AppSpacing.card),
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
          const Icon(
            CupertinoIcons.right_chevron,
            size: 20,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: 4,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: item,
      ),
    );
  }
}
