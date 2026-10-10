import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/club_logo.dart';
import '../../../dashboard/domain/admin_workspace_state.dart';
import '../../domain/models/tournament_clock_model.dart';
import '../../domain/providers/tournament_clock_provider.dart';
import '../../domain/providers/tournament_grid_provider.dart';

class _TVSettingsSheet extends ConsumerStatefulWidget {
  const _TVSettingsSheet();

  @override
  ConsumerState<_TVSettingsSheet> createState() => _TVSettingsSheetState();
}

class _TVSettingsSheetState extends ConsumerState<_TVSettingsSheet> {
  late BackgroundTheme selectedTheme;
  late List<BlindLevel> levels;
  late final TextEditingController nameController;
  late final TextEditingController colorController;
  TournamentGrid? selectedPreset;

  @override
  void initState() {
    super.initState();
    final clockState = ref.read(tournamentClockProvider);
    selectedTheme = clockState.backgroundTheme;
    levels = List<BlindLevel>.from(ref.read(tournamentBlindLevelsProvider));
    nameController = TextEditingController(text: clockState.tournamentName);
    colorController = TextEditingController(
      text: clockState.customBackgroundColor == null
          ? ''
          : clockState.customBackgroundColor!.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase(),
    );
    selectedPreset = _findPresetForName(clockState.tournamentName);
  }

  @override
  void dispose() {
    nameController.dispose();
    colorController.dispose();
    super.dispose();
  }

  TournamentGrid? _findPresetForName(String value) {
    final presets = ref.read(tournamentGridsProvider);
    final normalized = value.trim().toLowerCase();
    for (final preset in presets) {
      if (preset.name.trim().toLowerCase() == normalized) {
        return preset;
      }
    }
    return null;
  }

  void _apply() {
    final normalized = colorController.text.trim().replaceAll('#', '').trim();
    final parsed = normalized.isEmpty ? null : int.tryParse(normalized, radix: 16);
    final customColor = parsed == null ? null : Color(parsed + 0xFF000000);

    final name = nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(tournamentClockProvider.notifier).updateTournamentName(name);
    }

    ref.read(tournamentBlindLevelsProvider.notifier).setLevels(levels);
    ref.read(tournamentClockProvider.notifier).updateBackgroundTheme(selectedTheme);
    ref.read(tournamentClockProvider.notifier).updateCustomBackgroundColor(customColor);
    Navigator.of(context).pop();
  }

  Future<void> _savePreset() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final preset = TournamentGrid(
      name: name,
      levels: List<BlindLevel>.from(levels),
      backgroundTheme: selectedTheme,
      tvLogoUrl: ref.read(tournamentClockProvider).tvLogoUrl,
    );

    await ref.read(tournamentGridsProvider.notifier).saveGrid(preset);
    final saved = ref.read(tournamentGridsProvider).firstWhere(
      (item) => item.name.trim().toLowerCase() == name.toLowerCase(),
      orElse: () => preset,
    );

    if (mounted) {
      setState(() {
        selectedPreset = saved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedPresets = ref.watch(tournamentGridsProvider);
    final selectedValue = savedPresets.isEmpty
        ? null
        : (savedPresets.any((preset) => preset.name.trim().toLowerCase() == nameController.text.trim().toLowerCase())
            ? savedPresets.firstWhere(
                (preset) => preset.name.trim().toLowerCase() == nameController.text.trim().toLowerCase(),
              )
            : selectedPreset);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Настройки ТВ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название турнира',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TournamentGrid>(
                value: selectedValue,
                isExpanded: true,
                hint: const Text('Выбрать сохранённый вариант'),
                decoration: const InputDecoration(
                  labelText: 'Вариант турнира',
                  border: OutlineInputBorder(),
                ),
                items: savedPresets
                    .map((preset) => DropdownMenuItem<TournamentGrid>(
                          value: preset,
                          child: Text(preset.name),
                        ))
                    .toList(),
                onChanged: (preset) {
                  if (preset == null) return;
                  setState(() {
                    selectedPreset = preset;
                    nameController.text = preset.name;
                    levels = List<BlindLevel>.from(preset.levels);
                  });
                  ref.read(selectedGridProvider.notifier).selectGrid(preset);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _savePreset,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Сохранить вариант'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Тема фона', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<BackgroundTheme>(
                value: selectedTheme,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: BackgroundTheme.values
                    .map((theme) => DropdownMenuItem(value: theme, child: Text(theme.displayName)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedTheme = value);
                },
              ),
              const SizedBox(height: 16),
              const Text('Цвет фона', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  hintText: 'AABBCC',
                  border: OutlineInputBorder(),
                  prefixText: '#',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('Блайнды', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        levels = [
                          ...levels,
                          BlindLevel(
                            level: levels.isEmpty ? 1 : levels.last.level + 1,
                            durationMinutes: 15,
                            smallBlind: 25,
                            bigBlind: 50,
                            ante: 0,
                          ),
                        ];
                      });
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                level.isBreak ? 'Break ${level.level}' : 'Level ${level.level}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    levels[index] = level.copyWith(isBreak: !level.isBreak);
                                  });
                                },
                                icon: Icon(
                                  level.isBreak ? Icons.pause_circle_filled_rounded : Icons.pause_circle_outline_rounded,
                                  size: 18,
                                ),
                                label: Text(level.isBreak ? 'Пауза' : 'Перерыв'),
                              ),
                              if (levels.length > 1)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      levels.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (!level.isBreak)
                            Row(
                              children: [
                                Expanded(
                                  child: _LevelField(
                                    label: 'SB',
                                    value: level.smallBlind.toString(),
                                    onChanged: (value) {
                                      final parsed = int.tryParse(value) ?? level.smallBlind;
                                      setState(() {
                                        levels[index] = level.copyWith(smallBlind: parsed);
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _LevelField(
                                    label: 'BB',
                                    value: level.bigBlind.toString(),
                                    onChanged: (value) {
                                      final parsed = int.tryParse(value) ?? level.bigBlind;
                                      setState(() {
                                        levels[index] = level.copyWith(bigBlind: parsed);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          if (!level.isBreak)
                            Row(
                              children: [
                                Expanded(
                                  child: _LevelField(
                                    label: 'Ante',
                                    value: level.ante.toString(),
                                    onChanged: (value) {
                                      final parsed = int.tryParse(value) ?? level.ante;
                                      setState(() {
                                        levels[index] = level.copyWith(ante: parsed);
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _LevelField(
                                    label: 'Мин',
                                    value: level.durationMinutes.toString(),
                                    onChanged: (value) {
                                      final parsed = int.tryParse(value) ?? level.durationMinutes;
                                      setState(() {
                                        levels[index] = level.copyWith(durationMinutes: parsed);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: _LevelField(
                                    label: 'Мин',
                                    value: level.durationMinutes.toString(),
                                    onChanged: (value) {
                                      final parsed = int.tryParse(value) ?? level.durationMinutes;
                                      setState(() {
                                        levels[index] = level.copyWith(durationMinutes: parsed);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _apply,
                    child: const Text('Применить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _LevelField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}

class TournamentClockTVScreen extends ConsumerStatefulWidget {
  const TournamentClockTVScreen({super.key});

  @override
  ConsumerState<TournamentClockTVScreen> createState() => _TournamentClockTVScreenState();
}

class _TournamentClockTVScreenState extends ConsumerState<TournamentClockTVScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).floor();
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleTogglePause() {
    final state = ref.read(tournamentClockProvider);
    final levels = ref.read(tournamentBlindLevelsProvider);

    if (state.isRunning) {
      ref.read(tournamentClockProvider.notifier).togglePause();
      return;
    }

    if (levels.isNotEmpty) {
      ref.read(tournamentClockProvider.notifier).start(
        levels,
        state.currentLevel > 0 ? state.currentLevel : 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clockState = ref.watch(tournamentClockProvider);
    final blindLevels = ref.watch(tournamentBlindLevelsProvider);
    final workspace = ref.watch(adminWorkspaceProvider);
    final currentLevel = blindLevels.isEmpty
        ? null
        : blindLevels.elementAtOrNull(clockState.currentLevel.clamp(0, blindLevels.length - 1));

    // Вычисляем время до следующего перерыва
    String? nextBreakLabel;
    if (currentLevel != null && !currentLevel.isBreak) {
      int totalSecondsToBreak = 0;
      for (int i = clockState.currentLevel + 1; i < blindLevels.length; i++) {
        final level = blindLevels[i];
        if (level.isBreak) {
          nextBreakLabel = totalSecondsToBreak ~/ 60 == 1
              ? '1 минута до перерыва'
              : '${totalSecondsToBreak ~/ 60} минут до перерыва';
          break;
        } else {
          totalSecondsToBreak += level.durationMinutes * 60;
        }
      }
    }

    final theme = clockState.backgroundTheme;
    final backgroundColors = clockState.customBackgroundColor != null
        ? [
            clockState.customBackgroundColor!,
            clockState.customBackgroundColor!.withOpacity(0.9),
          ]
        : theme.colors;
    final logoUrl = workspace.logoUrl.trim().isNotEmpty ? workspace.logoUrl : null;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.space) {
            _handleTogglePause();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: backgroundColors,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 36,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: Opacity(
                        opacity: 0.18,
                        child: ClubLogo(
                          logoUrl: logoUrl,
                          size: 420,
                          borderRadius: 96,
                          borderWidth: 2,
                          borderColor: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
                  child: Column(
                    children: [
                      // Top bar
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                clockState.tournamentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.black.withOpacity(0.85),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        builder: (_) => const _TVSettingsSheet(),
                                      );
                                    },
                                    icon: const Icon(Icons.settings_rounded, color: Colors.white),
                                    tooltip: 'Настройки ТВ',
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      clockState.isRunning ? 'LIVE' : 'WAITING',
                                      style: TextStyle(
                                        color: theme.accentColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Positioned(
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              ignoring: true,
                              child: Text(
                                'ВЕГАС',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Main timer centered + next break info on right
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _formatTime(clockState.timeRemaining),
                                  style: TextStyle(
                                    color: const Color(0xFFEAB749),
                                    fontSize: 200,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                    letterSpacing: 1,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFFEAB749).withValues(alpha: 0.3),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'УРОВЕНЬ ${currentLevel?.level ?? 1}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.62),
                                  fontSize: 22,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (currentLevel != null && !currentLevel.isBreak)
                                Center(
                                  child: _BlindStatsRow(
                                    level: currentLevel,
                                    isNext: false,
                                    isCurrent: true,
                                  ),
                                ),
                            ],
                          ),
                          if (nextBreakLabel != null && currentLevel != null && !currentLevel.isBreak)
                            Positioned(
                              right: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'СЛЕДУЮЩИЙ',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'ПЕРЕРЫВ',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    nextBreakLabel,
                                    style: const TextStyle(
                                      color: Color(0xFFEAB749),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlindStatsRow extends StatelessWidget {
  final BlindLevel level;
  final bool isNext;
  final bool isCurrent;

  const _BlindStatsRow({required this.level, this.isNext = false, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    final stats = <_BlindStatItem>[
      _BlindStatItem(label: 'SB', value: '${level.smallBlind}'),
      _BlindStatItem(label: 'BB', value: '${level.bigBlind}'),
    ];

    if (level.ante > 0) {
      stats.add(_BlindStatItem(label: 'ANTE', value: '${level.ante}'));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stats.map((stat) {
        return         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _BlindStatBox(
            label: stat.label,
            value: stat.value,
            isNext: isNext,
            isCurrent: isCurrent,
          ),
        );
      }).toList(),
    );
  }
}

class _BlindStatItem {
  final String label;
  final String value;
  const _BlindStatItem({required this.label, required this.value});
}

class _BlindStatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isNext;
  final bool isCurrent;

  const _BlindStatBox({required this.label, required this.value, required this.isNext, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFEAB749);
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isCurrent ? goldColor : (isNext ? Colors.white.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.65)),
            fontSize: isCurrent ? 33 : (isNext ? 18 : 22),
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: isCurrent ? goldColor : (isNext ? Colors.white.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.88)),
            fontSize: isCurrent ? 78 : (isNext ? 42 : 52),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

