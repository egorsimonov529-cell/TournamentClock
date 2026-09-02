from pathlib import Path

root = Path(__file__).resolve().parents[1]

def write(relative: str, content: str) -> None:
    (root / relative).write_text(content, encoding="utf-8", newline="\n")

write("lib/features/player/presentation/pages/player_dashboard_page.dart", r'''import 'package:flutter/material.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
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

  static final _demoPlayer = PlayerProfile(
    userId: 'demo-player',
    login: 'ivan.petrov',
    email: 'ivan@example.com',
    firstName: 'Иван',
    lastName: 'Петров',
    role: 'player',
    level: 1,
    xp: 0,
    xpToNextLevel: 100,
    rank: 0,
    rankPoints: 0,
    rpsRank: RpsRank.fish,
    winRate: 0,
    totalTournaments: 0,
    totalWins: 0,
    totalPodiums: 0,
    totalProfit: 0,
    averageScore: 0,
    balance: 25000,
    createdAt: DateTime(2026),
    lastLoginAt: DateTime(2026),
  );

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
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
                        ProfileSettingsPage(player: _demoPlayer),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.emoji_events_rounded,
                      title: 'Мои турниры',
                      onTap: () => _openPage(
                        context,
                        const MyTournamentsPage(),
                      ),
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
              subtitle:
                  'Еженедельный турнир с гарантированным призовым фондом',
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff151921),
        border: Border(
          bottom: BorderSide(color: Color(0xff252C28), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Иван Петров',
                style: TextStyle(
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
                onPressed: () =>
                    _openPage(context, const NotificationsPage()),
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
''')

write("lib/features/player/presentation/pages/tournament_detail_page.dart", r'''import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/screen_widgets.dart';

class TournamentDetailPage extends StatefulWidget {
  final String tournamentId;

  const TournamentDetailPage({super.key, required this.tournamentId});

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  int _selectedTab = 0;
  bool _registered = false;

  static const _tabs = ['О турнире', 'Структура', 'Игроки'];
  static const _content = [
    'Deepstack турнир с замедленной структурой. Поздняя регистрация до 22:00. Re-entry разрешен. Add-on после 2-го уровня.',
    'Уровни по 15 минут. Стартовые блайнды 25/50. Перерыв после каждого четвёртого уровня.',
    'Зарегистрировано 48 игроков из 100. Список участников обновляется после подтверждения регистрации.',
  ];

  Future<void> _toggleRegistration() async {
    final action = _registered ? 'Отменить регистрацию' : 'Зарегистрироваться';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(action),
        content: Text(
          _registered
              ? 'Вы уверены, что хотите отменить регистрацию?'
              : 'Подтвердить регистрацию и списание бай-ина 2 000 ₽?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Назад'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _registered = !_registered);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _registered ? 'Регистрация подтверждена' : 'Регистрация отменена',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: ScreenTitle(title: 'Night Deepstack')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '15 августа 2026',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Начало: 21:00',
                        style: TextStyle(
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
                        color: AppColors.accent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Бай-ин',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '2 000 ₽',
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
          const SliverToBoxAdapter(child: SectionHeader(title: 'Информация')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: AppCard(
                child: Column(
                  children: [
                    _infoRow('Призовой фонд', '150 000 ₽', Icons.emoji_events),
                    const Divider(height: 24),
                    _infoRow('Стартовый стек', '10 000 очков', Icons.casino),
                    const Divider(height: 24),
                    _infoRow('Уровни', '15 минут', Icons.timer),
                    const Divider(height: 24),
                    _infoRow('Поздняя рег.', 'до 22:00', Icons.access_time),
                    const Divider(height: 24),
                    _infoRow('Re-entry', 'Да', Icons.refresh),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  return Expanded(
                    child: _TournamentTab(
                      label: _tabs[index],
                      selected: _selectedTab == index,
                      onTap: () => setState(() => _selectedTab = index),
                    ),
                  );
                }),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardLg),
              child: Text(
                _content[_selectedTab],
                key: ValueKey(_selectedTab),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: PrimaryButton(
                label: _registered
                    ? 'Отменить регистрацию'
                    : 'Зарегистрироваться',
                onPressed: _toggleRegistration,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _TournamentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TournamentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
''')

write("lib/features/dashboard/presentation/widgets/topbar/top_bar.dart", r'''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/domain/providers/auth_state_provider.dart';

class TopBar extends ConsumerStatefulWidget {
  final String sectionTitle;

  const TopBar({super.key, this.sectionTitle = 'Dashboard'});

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  bool _hasUnread = true;

  Future<void> _showNotifications() async {
    setState(() => _hasUnread = false);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Уведомления'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.emoji_events_outlined),
              title: Text('Регистрация открыта'),
              subtitle: Text('Night Deepstack начинается в 21:00'),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined),
              title: Text('Баланс пополнен'),
              subtitle: Text('Зачислено 5 000 ₽'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final avatarUrl = user?.avatarUrl?.trim();
    final login = user?.login ?? 'Администратор';
    final initial = login.isNotEmpty ? login[0].toUpperCase() : '?';

    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Добро пожаловать, $login! 👋',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                widget.sectionTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 320,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xff1D232C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Уведомления',
                onPressed: _showNotifications,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
              if (_hasUnread)
                const Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    key: ValueKey('unread-indicator'),
                    radius: 4,
                    backgroundColor: Colors.redAccent,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(initial)
                : null,
          ),
        ],
      ),
    );
  }
}
''')

write("test/features/player/tournament_detail_page_test.dart", r'''import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_clock/features/player/presentation/pages/tournament_detail_page.dart';

void main() {
  testWidgets('switches tabs and confirms registration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TournamentDetailPage(tournamentId: 'night-deepstack'),
      ),
    );

    await tester.tap(find.text('Структура'));
    await tester.pump();
    expect(find.textContaining('Стартовые блайнды'), findsOneWidget);

    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();
    expect(find.text('Подтвердить'), findsOneWidget);
    await tester.tap(find.text('Подтвердить'));
    await tester.pumpAndSettle();
    expect(find.text('Отменить регистрацию'), findsOneWidget);
  });
}
''')

write("test/features/player/player_dashboard_page_test.dart", r'''import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_clock/features/player/presentation/pages/player_dashboard_page.dart';
import 'package:tournament_clock/features/player/presentation/pages/profile_settings_page.dart';

void main() {
  testWidgets('profile CTA opens profile settings', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlayerDashboardPage()));
    await tester.tap(find.text('Мой профиль'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSettingsPage), findsOneWidget);
  });
}
''')
