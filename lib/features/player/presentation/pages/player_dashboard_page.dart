import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tournament/domain/models/tournament_model.dart' as tournament_models;
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../../../tournament_clock/domain/providers/tournament_clock_provider.dart';
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

class PlayerDashboardPage extends ConsumerWidget {
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

  void _showTournamentDetails(
    BuildContext context, {
    required String name,
    required String date,
    required String time,
    required String buyIn,
    required String prizePool,
    required String description,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1D232C),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Описание турнира',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Дата', '$date, $time'),
              _detailRow('Взнос', buyIn),
              _detailRow('Призовой фонд', prizePool),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  tournament_models.Tournament? _findActiveTournament(User? user, List<tournament_models.Tournament> tournaments) {
    if (user == null) return null;

    for (final tournament in tournaments) {
      final isRegistered = tournament.registeredPlayerIds.contains(user.id);
      final isEliminated = tournament.isPlayerEliminated(user.id);

      if (isRegistered && !isEliminated) {
        return tournament;
      }
    }

    return null;
  }

  String _formatClockTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(currentAuthUserProvider).valueOrNull;
    final tournaments = ref.watch(tournamentProvider);
    final clockState = ref.watch(tournamentClockProvider);
    final activeTournament = _findActiveTournament(authUser, tournaments);

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

    final nightDeepstack = tournaments.where(
      (t) => t.name.toLowerCase().contains('night') || t.name.toLowerCase().contains('deepstack'),
    ).firstOrNull;

    final sundaySpecial = tournaments.where(
      (t) => t.name.toLowerCase().contains('sunday') || t.name.toLowerCase().contains('special'),
    ).firstOrNull;

    final nightStatus = authUser == null || nightDeepstack == null
        ? null
        : nightDeepstack.registeredPlayerIds.contains(authUser.id)
            ? (nightDeepstack.isPlayerConfirmed(authUser.id)
                ? 'Подтверждён'
                : (nightDeepstack.isPlayerEliminated(authUser.id)
                    ? 'Выбыл'
                    : 'Ожидает подтверждения'))
            : null;

    final sundayStatus = authUser == null || sundaySpecial == null
        ? null
        : sundaySpecial.registeredPlayerIds.contains(authUser.id)
            ? (sundaySpecial.isPlayerConfirmed(authUser.id)
                ? 'Подтверждён'
                : (sundaySpecial.isPlayerEliminated(authUser.id)
                    ? 'Выбыл'
                    : 'Ожидает подтверждения'))
            : null;

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
          if (activeTournament != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B2330), Color(0xFF111821)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_fill_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Активный турнир',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'В игре',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        activeTournament.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_rounded,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatClockTime(clockState.timeRemaining),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.groups_rounded,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${activeTournament.currentPlayers}/${activeTournament.maxPlayers}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Участников в игре: ${activeTournament.currentPlayers} • уровень ${clockState.currentLevel + 1}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (activeTournament != null)
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
                  guestStatus: nightStatus,
                  onRegister: () => _openTournament(context),
                  onDetails: () => _showTournamentDetails(
                    context,
                    name: 'Night Deepstack',
                    date: '15 авг',
                    time: '21:00',
                    buyIn: '2 000 ₽',
                    prizePool: '150 000 ₽',
                    description:
                        'Ночной глубокий стек с акцентом на поздние уровни и высокую активность за столами. Формат: No-Limit Holdem. Призовой фонд формируется из входных взносов и пополнений.',
                  ),
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
                  guestStatus: sundayStatus,
                  onRegister: () => _showComingSoon(context),
                  onDetails: () => _showTournamentDetails(
                    context,
                    name: 'Sunday Special',
                    date: '17 авг',
                    time: '18:00',
                    buyIn: '1 000 ₽',
                    prizePool: '75 000 ₽',
                    description:
                        'Семейный воскресный турнир с комфортным уровнем buy-in и плавным стартом. Подходит для игроков, которые хотят начать день с качественной игры и стабильного формата.',
                  ),
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
    final isCompact = MediaQuery.of(context).size.width < 400;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: isCompact ? 10.0 : AppSpacing.md,
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
                style: TextStyle(
                  fontSize: isCompact ? 15 : 18,
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
                  size: 24,
                ),
                onPressed: () => _openPage(context, const NotificationsPage()),
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                radius: isCompact ? 16 : 20,
                backgroundColor: const Color(0x332E7D32),
                child: Icon(Icons.person, size: isCompact ? 16 : 20, color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
