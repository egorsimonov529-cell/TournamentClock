import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../domain/models/player_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_header.dart';
import '../widgets/tournament_list_item.dart';
import 'balance_page.dart';
import 'my_tournaments_page.dart';
import 'notifications_page.dart';
import 'profile_settings_page.dart';
import 'tournament_detail_page.dart';

class PlayerDashboardPage extends StatelessWidget {
  const PlayerDashboardPage({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _openTournament(BuildContext context) {
    _openPage(
      context,
      const TournamentDetailPage(tournamentId: 'night-deepstack'),
    );
  }

  void _showComingSoon(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('Регистрация на Sunday Special откроется позже'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Try to read auth state from ProviderScope if available. If not,
    // fall back to guest profile (this makes widget tests more robust).
    dynamic authUser;
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final authState = container.read(authStateProvider);
      authUser = authState.user;
    } catch (_) {
      authUser = null;
    }
    final player = authUser == null
        ? PlayerProfile(
            userId: 'guest',
            login: 'guest',
            email: 'guest@local',
            role: 'player',
            level: 1,
            xp: 0,
            xpToNextLevel: 100,
            rank: 0,
            rankPoints: 0,
            rpsPoints: 0,
            rpsRank: RpsRank.fish,
            winRate: 0,
            totalTournaments: 0,
            totalWins: 0,
            totalPodiums: 0,
            totalProfit: 0,
            averageScore: 0,
            balance: 0,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          )
        : PlayerProfile(
            userId: authUser.id,
            login: authUser.login,
            email: authUser.email,
            firstName: authUser.firstName,
            lastName: authUser.lastName,
            avatarUrl: authUser.avatarUrl,
            role: authUser.role,
            level: 1,
            xp: 0,
            xpToNextLevel: 100,
            rank: 0,
            rankPoints: 0,
            rpsPoints: 0,
            rpsRank: RpsRank.fish,
            winRate: 0,
            totalTournaments: 0,
            totalWins: 0,
            totalPodiums: 0,
            totalProfit: 0,
            averageScore: 0,
            balance: 0,
            createdAt: authUser.createdAt ?? DateTime.now(),
            lastLoginAt: authUser.lastLoginAt ?? DateTime.now(),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, player)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          const SliverToBoxAdapter(
            child: BalanceCard(
              label: 'Баланс',
              amount: '25 000 ₽',
              showDetails: true,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          const SliverToBoxAdapter(
            child: BalanceCard(
              label: 'Бонусы',
              amount: '5 000 ₽',
              icon: Icons.local_offer_rounded,
              accentColor: AppColors.gold,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Быстрые действия'),
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
                      title: 'Мой профиль',
                      onTap: () => _openPage(
                        context,
                        ProfileSettingsPage(player: player),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.emoji_events_rounded,
                      title: 'Мои турниры',
                      onTap: () =>
                          _openPage(context, const MyTournamentsPage()),
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
                  title: 'Касса',
                  onTap: () => _openPage(context, const BalancePage()),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(
            child: PromoBanner(
              title: 'POKER NIGHT',
              subtitle: 'Еженедельный турнир с гарантированным призовым фондом',
              cta: 'Участвовать',
              onCta: () => _openTournament(context),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Ближайшие турниры'),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TournamentListItem(
                  name: 'Night Deepstack',
                  date: '15 авг',
                  time: '21:00',
                  buyIn: '2 000 ₽',
                  prizePool: '150 000 ₽',
                  status: 'Регистрация',
                  onRegister: () => _openTournament(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TournamentListItem(
                  name: 'Sunday Special',
                  date: '17 авг',
                  time: '18:00',
                  buyIn: '1 000 ₽',
                  prizePool: '75 000 ₽',
                  status: 'Скоро',
                  onRegister: () => _showComingSoon(context),
                ),
              ),
            ]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PlayerProfile player) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff151921),
        border: Border(bottom: BorderSide(color: Color(0xff252C28), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${player.firstName ?? player.login} ${player.lastName ?? ''}'.trim(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'VIP Silver',
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
                tooltip: 'Уведомления',
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => _openPage(context, const NotificationsPage()),
              ),
              const SizedBox(width: AppSpacing.sm),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0x332E7D32),
                child: Icon(Icons.person, size: 20, color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
