import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/tournament_clock_model.dart';
import '../../domain/providers/tournament_clock_provider.dart';

class TournamentClockScreen extends ConsumerWidget {
  const TournamentClockScreen({super.key});

  static const blindLevels = [
    BlindLevel(
      level: 1,
      durationMinutes: 15,
      smallBlind: 25,
      bigBlind: 50,
      ante: 0,
    ),
    BlindLevel(
      level: 2,
      durationMinutes: 15,
      smallBlind: 50,
      bigBlind: 100,
      ante: 10,
    ),
    BlindLevel(
      level: 3,
      durationMinutes: 15,
      smallBlind: 100,
      bigBlind: 200,
      ante: 20,
    ),
    BlindLevel(
      level: 4,
      durationMinutes: 15,
      smallBlind: 150,
      bigBlind: 300,
      ante: 25,
    ),
    BlindLevel(
      level: 5,
      durationMinutes: 15,
      smallBlind: 200,
      bigBlind: 400,
      ante: 40,
    ),
    BlindLevel(
      level: 6,
      durationMinutes: 15,
      smallBlind: 300,
      bigBlind: 600,
      ante: 50,
    ),
    BlindLevel(
      level: 7,
      durationMinutes: 15,
      smallBlind: 400,
      bigBlind: 800,
      ante: 80,
    ),
    BlindLevel(
      level: 8,
      durationMinutes: 15,
      smallBlind: 500,
      bigBlind: 1000,
      ante: 100,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentClockProvider);
    final notifier = ref.read(tournamentClockProvider.notifier);
    final index = state.currentLevel.clamp(0, blindLevels.length - 1);
    final current = blindLevels[index];
    final next = index + 1 < blindLevels.length ? blindLevels[index + 1] : null;
    final isBreak = current.smallBlind == 0 && current.bigBlind == 0;
    final status = isBreak
        ? 'ПЕРЕРЫВ'
        : state.isPaused
        ? 'ПАУЗА'
        : state.isRunning
        ? 'ИДЁТ ИГРА'
        : 'ГОТОВ К СТАРТУ';
    final progress = state.isRunning && current.durationMinutes > 0
        ? 1 - state.timeRemaining / (current.durationMinutes * 60)
        : 0.0;

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 16 : 32,
                  compact ? 18 : 28,
                  compact ? 16 : 32,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(status: status, isPaused: state.isPaused),
                        SizedBox(height: compact ? 16 : 24),
                        if (compact) ...[
                          _ClockHero(
                            time: notifier.formattedTime,
                            current: current,
                            progress: progress.clamp(0, 1),
                            status: status,
                            isPaused: state.isPaused,
                            isBreak: isBreak,
                          ),
                          const SizedBox(height: 16),
                          _LevelPanel(current: current, next: next),
                        ] else
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _ClockHero(
                                    time: notifier.formattedTime,
                                    current: current,
                                    progress: progress.clamp(0, 1),
                                    status: status,
                                    isPaused: state.isPaused,
                                    isBreak: isBreak,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 4,
                                  child: _LevelPanel(
                                    current: current,
                                    next: next,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: compact ? 16 : 20),
                        _Controls(
                          isRunning: state.isRunning,
                          isPaused: state.isPaused,
                          canPrevious:
                              state.isRunning && !state.isPaused && index > 0,
                          canNext:
                              state.isRunning &&
                              !state.isPaused &&
                              next != null,
                          onPrimary: state.isRunning
                              ? notifier.togglePause
                              : () => notifier.start(blindLevels, index),
                          onPrevious: () => notifier.prevLevel(blindLevels),
                          onNext: () => notifier.nextLevel(blindLevels),
                          onReset: notifier.stop,
                        ),
                        SizedBox(height: compact ? 16 : 20),
                        _StatsGrid(
                          compact: compact,
                          level: current.level,
                          totalLevels: blindLevels.length,
                          duration: current.durationMinutes,
                          ante: current.ante,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(-0.65, -0.8),
        radius: 1.35,
        colors: [AppColors.primary.withValues(alpha: .18), Colors.transparent],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.status, required this.isPaused});
  final String status;
  final bool isPaused;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.goldLight, AppColors.gold],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: .2),
              blurRadius: 24,
            ),
          ],
        ),
        child: const Icon(Icons.emoji_events_rounded, color: Color(0xff17130B)),
      ),
      const SizedBox(width: 14),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SUNDAY MEGA',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'No-Limit Hold’em • Tournament clock',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
      _StatusPill(label: status, paused: isPaused),
    ],
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.paused});
  final String label;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final color = paused ? AppColors.warning : AppColors.accent;
    return Semantics(
      label: 'Статус турнира: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: .35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClockHero extends StatelessWidget {
  const _ClockHero({
    required this.time,
    required this.current,
    required this.progress,
    required this.status,
    required this.isPaused,
    required this.isBreak,
  });
  final String time;
  final BlindLevel current;
  final double progress;
  final String status;
  final bool isPaused;
  final bool isBreak;

  @override
  Widget build(BuildContext context) {
    final accent = isPaused || isBreak ? AppColors.warning : AppColors.gold;
    return Semantics(
      label:
          '$status. Осталось $time. Блайнды ${current.smallBlind} / ${current.bigBlind}. Анте ${current.ante}',
      liveRegion: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .93),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accent.withValues(alpha: isPaused ? .55 : .28),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: .08),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBreak ? 'ПЕРЕРЫВ' : 'ДО КОНЦА УРОВНЯ',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  time,
                  key: ValueKey(time),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 112,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                color: accent,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'УРОВЕНЬ ${current.level}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelPanel extends StatelessWidget {
  const _LevelPanel({required this.current, required this.next});
  final BlindLevel current;
  final BlindLevel? next;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.card.withValues(alpha: .96),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'ТЕКУЩИЕ БЛАЙНДЫ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '${_number(current.smallBlind)} / ${_number(current.bigBlind)}',
            style: const TextStyle(
              fontSize: 43,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _AnteChip(value: current.ante),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(),
        ),
        const Text(
          'СЛЕДУЮЩИЙ УРОВЕНЬ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        if (next != null) ...[
          Text(
            '${_number(next!.smallBlind)} / ${_number(next!.bigBlind)}',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            'Анте ${_number(next!.ante)}  •  ${next!.durationMinutes} мин',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ] else
          const Text(
            'Финальный уровень',
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    ),
  );
}

class _AnteChip extends StatelessWidget {
  const _AnteChip({required this.value});
  final int value;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.gold.withValues(alpha: .28)),
      ),
      child: Text(
        'ANTE  ${_number(value)}',
        style: const TextStyle(
          color: AppColors.goldLight,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
    ),
  );
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.isRunning,
    required this.isPaused,
    required this.canPrevious,
    required this.canNext,
    required this.onPrimary,
    required this.onPrevious,
    required this.onNext,
    required this.onReset,
  });
  final bool isRunning;
  final bool isPaused;
  final bool canPrevious;
  final bool canNext;
  final VoidCallback onPrimary;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        _ControlIcon(
          icon: Icons.skip_previous_rounded,
          tooltip: 'Предыдущий уровень',
          semantic: 'Перейти на предыдущий уровень',
          onPressed: canPrevious ? onPrevious : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            button: true,
            label: !isRunning
                ? 'Запустить таймер'
                : isPaused
                ? 'Продолжить таймер'
                : 'Поставить таймер на паузу',
            child: FilledButton.icon(
              key: const Key('clock-primary-control'),
              onPressed: onPrimary,
              icon: Icon(
                !isRunning || isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
              ),
              label: Text(
                !isRunning
                    ? 'СТАРТ'
                    : isPaused
                    ? 'ПРОДОЛЖИТЬ'
                    : 'ПАУЗА',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isRunning && !isPaused
                    ? AppColors.warning
                    : AppColors.primaryLight,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _ControlIcon(
          icon: Icons.skip_next_rounded,
          tooltip: 'Следующий уровень',
          semantic: 'Перейти на следующий уровень',
          onPressed: canNext ? onNext : null,
        ),
        const SizedBox(width: 10),
        _ControlIcon(
          icon: Icons.restart_alt_rounded,
          tooltip: 'Сбросить таймер',
          semantic: 'Сбросить турнирный таймер',
          onPressed: isRunning ? onReset : null,
          destructive: true,
        ),
      ],
    ),
  );
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({
    required this.icon,
    required this.tooltip,
    required this.semantic,
    required this.onPressed,
    this.destructive = false,
  });
  final IconData icon;
  final String tooltip;
  final String semantic;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semantic,
    enabled: onPressed != null,
    child: IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: destructive ? AppColors.error : AppColors.white,
      disabledColor: AppColors.textMuted,
      style: IconButton.styleFrom(
        minimumSize: const Size(52, 52),
        backgroundColor: destructive
            ? AppColors.error.withValues(alpha: .08)
            : AppColors.cardSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.compact,
    required this.level,
    required this.totalLevels,
    required this.duration,
    required this.ante,
  });
  final bool compact;
  final int level;
  final int totalLevels;
  final int duration;
  final int ante;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: Icons.layers_rounded,
        label: 'СТРУКТУРА',
        value: '$level / $totalLevels',
        detail: 'текущий уровень',
      ),
      _StatCard(
        icon: Icons.schedule_rounded,
        label: 'ДЛИТЕЛЬНОСТЬ',
        value: '$duration мин',
        detail: 'на один уровень',
      ),
      _StatCard(
        icon: Icons.paid_rounded,
        label: 'АНТЕ',
        value: _number(ante),
        detail: ante == 0 ? 'пока не активен' : 'на каждого игрока',
      ),
    ];
    return compact
        ? Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 10),
              ],
            ],
          )
        : Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _number(int value) {
  final raw = value.toString();
  return raw.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
}
