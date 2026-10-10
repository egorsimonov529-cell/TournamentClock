import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../../core/models/rps_rank.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../../tournament/domain/providers/tournament_provider.dart';
import '../../domain/models/seating_models.dart';
import '../../domain/providers/seating_provider.dart';

class SeatingScreen extends ConsumerStatefulWidget {
  final String tournamentId;

  const SeatingScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<SeatingScreen> createState() => _SeatingScreenState();
}

class _SeatingScreenState extends ConsumerState<SeatingScreen> {
  String get tournamentId => widget.tournamentId;
  int selectedTableIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seatingProvider(tournamentId).notifier).refresh();
    });
  }

  void _showAssignPlayerDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(seatingProvider(tournamentId));
    final table = state.tables[selectedTableIndex];
    final freeSeats = table.seats.where((s) => s.status == SeatStatus.free).toList();
    
    if (freeSeats.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет свободных мест на этом столе')),
        );
      }
      return;
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Посадить игрока'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Выберите игрока:'),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: state.unseatedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = state.unseatedPlayers[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(player.name),
                      onTap: () {
                        Navigator.pop(dialogContext, player);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
        ],
      ),
    ).then((selectedPlayer) async {
      if (selectedPlayer != null && context.mounted) {
        final seat = await showDialog<TableSeat>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Выберите место для ${selectedPlayer.name}'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Свободные места:'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: freeSeats.length,
                      itemBuilder: (context, index) {
                        final seat = freeSeats[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${seat.number}'),
                          ),
                          title: const Text('Свободно'),
                          onTap: () {
                            Navigator.pop(dialogContext, seat);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Отмена'),
              ),
            ],
          ),
        );
        
        if (seat != null) {
          final notifier = ref.read(seatingProvider(tournamentId).notifier);
          await notifier.assignPlayer(selectedPlayer.id, seat.number);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${selectedPlayer.name} посажен за стол ${table.name} на место ${seat.number}'),
                backgroundColor: AppColors.accent,
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seatingProvider(tournamentId));
    final tournaments = ref.watch(tournamentProvider);
    final tournament = tournaments
        .where((item) => item.id == tournamentId)
        .firstOrNull;
    final authUser = ref.watch(currentAuthUserProvider).valueOrNull;
    final normalizedRole = (authUser?.role ?? '').trim().toLowerCase();
    final isAdmin = const {'admin', 'super_admin', 'superadmin', 'administrator'}
        .contains(normalizedRole);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Рассадка',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            Text(
              tournament?.name ?? 'Турнир',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: () async {
              await ref.read(seatingProvider(tournamentId).notifier).refresh();
            },
          ),
          if (isAdmin && state.unseatedPlayers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.person_add, color: AppColors.accent),
              onPressed: () => _showAssignPlayerDialog(context, ref),
              tooltip: 'Посадить игрока',
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.accent),
              onPressed: () async {
                await ref.read(seatingProvider(tournamentId).notifier).addTable();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Стол добавлен')),
                  );
                }
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.groups, color: AppColors.accent),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Авторассадка'),
                    content: const Text('Автоматически распределить всех игроков по столам?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Отмена'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Рассадить'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true && mounted) {
                  ref.read(seatingProvider(tournamentId).notifier).autoSeat();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Игроки рассажены по столам'),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                }
              },
              tooltip: 'Авторассадка',
            ),
        ],
      ),
      body: state.tables.isEmpty
          ? Center(
              child: IosCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.table_chart, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        isAdmin ? 'Нажмите + чтобы добавить стол' : 'Столы ещё не созданы',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                if (state.tables.length > 1)
                  Container(
                    height: 50,
                    color: AppColors.surface,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: state.tables.length,
                      itemBuilder: (context, index) {
                        final table = state.tables[index];
                        final isSelected = index == selectedTableIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Material(
                            color: isSelected ? AppColors.accent : AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => setState(() => selectedTableIndex = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text(
                                  table.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.background : AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: _RoundTableCanvas(
                    table: state.tables[selectedTableIndex],
                    tournamentId: tournamentId,
                  ),
                ),
              ],
            ),
    );
  }
}

class _RoundTableCanvas extends ConsumerStatefulWidget {
  final PokerTable table;
  final String tournamentId;

  const _RoundTableCanvas({required this.table, required this.tournamentId});

  @override
  ConsumerState<_RoundTableCanvas> createState() => _RoundTableCanvasState();
}

class _RoundTableCanvasState extends ConsumerState<_RoundTableCanvas> {
  Offset? _selectedSeat;

  void _handleTap(TapDownDetails details, Size size) {
    final table = widget.table;
    final usableWidth = size.width * 0.9;
    final usableHeight = size.height * 0.72;
    final tableWidth = math.min(usableWidth, usableHeight * 1.3);
    final tableHeight = tableWidth * 0.68;
    final seatWidth = math.min(size.width * 0.18, 92.0);
    final seatHeight = 52.0;
    final centerX = size.width / 2;
    final centerY = size.height * 0.52;
    final seatRadiusX = tableWidth / 2 + seatWidth * 0.7;
    final seatRadiusY = tableHeight / 2 + seatHeight * 0.8;
    final numSeats = table.seats.length;

    for (var i = 0; i < numSeats; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / numSeats);
      final seatX = centerX + math.cos(angle) * seatRadiusX;
      final seatY = centerY + math.sin(angle) * seatRadiusY;

      final localX = details.localPosition.dx;
      final localY = details.localPosition.dy;

      if (localX >= seatX - seatWidth / 2 &&
          localX <= seatX + seatWidth / 2 &&
          localY >= seatY - seatHeight / 2 &&
          localY <= seatY + seatHeight / 2) {
        _handleSeatTap(table.seats[i]);
        return;
      }
    }
  }

  void _handleSeatTap(TableSeat seat) async {
    final authUser = ref.read(currentAuthUserProvider).valueOrNull;
    final normalizedRole = (authUser?.role ?? '').trim().toLowerCase();
    final isAdmin = const {'admin', 'super_admin', 'superadmin', 'administrator'}
        .contains(normalizedRole);
    
    final isBookedByMe = seat.isBookedByMe;
    final isOccupied = seat.status == SeatStatus.occupied;
    final isFree = seat.status == SeatStatus.free;

    if (isBookedByMe) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Отменить бронирование?'),
          content: Text('Вы освободите место ${seat.number}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Оставить'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Отменить'),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        final success = await ref.read(seatingProvider(widget.tournamentId).notifier).cancelSeat(seat.number);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Бронирование отменено' : 'Ошибка'),
              backgroundColor: success ? AppColors.accent : Colors.red,
            ),
          );
        }
      }
    } else if (isOccupied && isAdmin) {
      // Админ может освободить место игрока
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Освободить место?'),
          content: Text('Вы освободите место ${seat.number} для игрока ${seat.player?.name ?? "?"}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Освободить'),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        final success = await ref.read(seatingProvider(widget.tournamentId).notifier).releaseSeat(seat.number);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Место освобождено' : 'Ошибка'),
              backgroundColor: success ? AppColors.accent : Colors.red,
            ),
          );
        }
      }
    } else if (isFree) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Забронировать место?'),
          content: Text('Вы займёте место ${seat.number} за столом.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Забронировать'),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        final success = await ref.read(seatingProvider(widget.tournamentId).notifier).bookSeat(seat.number);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Место забронировано' : 'Ошибка'),
              backgroundColor: success ? AppColors.accent : Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final geometry = _resolveSeatGeometry(size);

        return Stack(
          children: [
            CustomPaint(
              size: size,
              painter: _TablePainter(
                table: widget.table,
                size: size,
              ),
            ),
            ...List.generate(widget.table.seats.length, (index) {
              final seat = widget.table.seats[index];
              final seatX = geometry.centerX + math.cos(-math.pi / 2 + (2 * math.pi * index / widget.table.seats.length)) * geometry.seatRadiusX;
              final seatY = geometry.centerY + math.sin(-math.pi / 2 + (2 * math.pi * index / widget.table.seats.length)) * geometry.seatRadiusY;

              return Positioned(
                left: seatX - geometry.seatWidth / 2,
                top: seatY - geometry.seatHeight / 2,
                width: geometry.seatWidth,
                height: geometry.seatHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _handleSeatTap(seat),
                  child: const SizedBox.expand(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  _SeatGeometry _resolveSeatGeometry(Size size) {
    final tableWidth = math.min(size.width * 0.62, 260.0);
    final tableHeight = math.min(size.height * 0.72, 420.0);
    final seatWidth = math.min(math.max(size.width * 0.16, 58.0), 94.0);
    final seatHeight = math.min(math.max(size.height * 0.09, 54.0), 72.0);
    final centerX = size.width / 2;
    final centerY = size.height * 0.52;
    final seatRadiusX = tableWidth / 2 + seatWidth * 0.74;
    final seatRadiusY = tableHeight / 2 + seatHeight * 0.9;

    return _SeatGeometry(
      centerX: centerX,
      centerY: centerY,
      seatWidth: seatWidth,
      seatHeight: seatHeight,
      seatRadiusX: seatRadiusX,
      seatRadiusY: seatRadiusY,
    );
  }
}

class _SeatGeometry {
  final double centerX;
  final double centerY;
  final double seatWidth;
  final double seatHeight;
  final double seatRadiusX;
  final double seatRadiusY;

  const _SeatGeometry({
    required this.centerX,
    required this.centerY,
    required this.seatWidth,
    required this.seatHeight,
    required this.seatRadiusX,
    required this.seatRadiusY,
  });
}

class _TablePainter extends CustomPainter {
  final PokerTable table;
  final Size size;

  _TablePainter({required this.table, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.52;
    final tableWidth = math.min(size.width * 0.62, 260.0);
    final tableHeight = math.min(size.height * 0.72, 420.0);
    final seatWidth = math.min(math.max(size.width * 0.16, 58.0), 94.0);
    final seatHeight = math.min(math.max(size.height * 0.09, 54.0), 72.0);
    final seatRadiusX = tableWidth / 2 + seatWidth * 0.74;
    final seatRadiusY = tableHeight / 2 + seatHeight * 0.9;
    final numSeats = table.seats.length;

    // Draw legend
    var legendX = 16.0;
    for (final item in [
      ('Свободно', AppColors.input),
      ('Занято', AppColors.cardPrimary),
      ('Ваше место', AppColors.accent),
    ]) {
      canvas.drawCircle(
        Offset(legendX + 5, 13),
        5,
        Paint()..color = item.$2..style = PaintingStyle.fill,
      );
      final textPainter = TextPainter(
        text: TextSpan(text: item.$1, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(legendX + 12, 8));
      legendX += 12 + 12 + textPainter.width + 12;
    }

    final ovalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY), width: tableWidth, height: tableHeight),
      const Radius.circular(80),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, centerY + 10), width: tableWidth, height: tableHeight),
        const Radius.circular(80),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.6)..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    final tableGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xff1b7d57),
        const Color(0xff0d4f2f),
        const Color(0xff0f5a37),
      ],
    );
    canvas.drawRRect(ovalRect, Paint()..shader = tableGradient.createShader(ovalRect.outerRect));
    canvas.drawRRect(ovalRect, Paint()..color = const Color(0xff203A3B)..style = PaintingStyle.stroke..strokeWidth = 8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, centerY), width: tableWidth - 12, height: tableHeight - 12),
        const Radius.circular(74),
      ),
      Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 3,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, centerY), width: tableWidth - 24, height: tableHeight - 24),
        const Radius.circular(68),
      ),
      Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // Table text
    final tableText = TextPainter(
      text: TextSpan(text: table.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      textDirection: TextDirection.ltr,
    );
    tableText.layout();
    tableText.paint(canvas, Offset(centerX - tableText.width / 2, centerY - 10));

    final countText = TextPainter(
      text: TextSpan(text: '${table.occupiedCount}/${table.capacity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent)),
      textDirection: TextDirection.ltr,
    );
    countText.layout();
    countText.paint(canvas, Offset(centerX - countText.width / 2, centerY + 18));

    // Draw seats
    for (var i = 0; i < numSeats; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / numSeats);
      final seatX = centerX + math.cos(angle) * seatRadiusX;
      final seatY = centerY + math.sin(angle) * seatRadiusY;

      final seat = table.seats[i];
      final isBookedByMe = seat.isBookedByMe;
      final isOccupied = seat.status == SeatStatus.occupied;
      final isFree = seat.status == SeatStatus.free;

      Color bgColor, borderColor, textColor;
      if (isBookedByMe) {
        bgColor = AppColors.accent.withValues(alpha: 0.25);
        borderColor = AppColors.accent;
        textColor = AppColors.accent;
      } else if (isOccupied) {
        bgColor = AppColors.cardPrimary;
        borderColor = AppColors.border;
        textColor = AppColors.white;
      } else {
        bgColor = AppColors.input;
        borderColor = AppColors.border;
        textColor = AppColors.textSecondary;
      }

      // Seat background
      final chipRadius = seatWidth * 0.52;
      canvas.drawCircle(Offset(seatX, seatY), chipRadius, Paint()..color = bgColor..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(seatX, seatY), chipRadius, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawCircle(Offset(seatX, seatY), chipRadius * 0.6, Paint()..color = bgColor.withValues(alpha: 0.82)..style = PaintingStyle.fill);

      final numText = TextPainter(
        text: TextSpan(text: '${seat.number}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isBookedByMe ? AppColors.accent : AppColors.white)),
        textDirection: TextDirection.ltr,
      );
      numText.layout();
      numText.paint(canvas, Offset(seatX - numText.width / 2, seatY - 12));

      final playerLabel = seat.player?.name ?? (isFree ? 'Свободно' : 'Занято');
      final nameText = TextPainter(
        text: TextSpan(text: playerLabel, style: TextStyle(fontSize: 9.5, fontWeight: isBookedByMe ? FontWeight.w600 : FontWeight.normal, color: textColor)),
        textDirection: TextDirection.ltr,
      );
      nameText.layout();
      nameText.paint(canvas, Offset(seatX - nameText.width / 2, seatY + 2));

      if (isOccupied && seat.player != null) {
        _drawRankBadge(canvas, seat.player!.rpsRank, seatX, seatY + chipRadius * 0.9);
      } else if (isBookedByMe) {
        canvas.drawCircle(Offset(seatX, seatY + chipRadius * 0.92), 5, Paint()..color = AppColors.accent..style = PaintingStyle.fill);
      }
    }
  }

  void _drawRankBadge(Canvas canvas, RpsRank rank, double x, double y) {
    Color rankColor;
    String rankLabel;
    switch (rank) {
      case RpsRank.fish:
        rankColor = const Color(0xFF8B4513);
        rankLabel = 'Fish';
        break;
      case RpsRank.bronze:
        rankColor = const Color(0xFFCD7F32);
        rankLabel = 'Bronze';
        break;
      case RpsRank.silver:
        rankColor = const Color(0xFFC0C0C0);
        rankLabel = 'Silver';
        break;
      case RpsRank.gold:
        rankColor = const Color(0xFFFFD700);
        rankLabel = 'Gold';
        break;
      case RpsRank.platinum:
        rankColor = const Color(0xFFE5E4E2);
        rankLabel = 'Platinum';
        break;
    }

    final badgeText = TextPainter(
      text: TextSpan(text: rankLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: rankColor)),
      textDirection: TextDirection.ltr,
    );
    badgeText.layout();

    final badgeWidth = badgeText.width + 10;
    final badgeHeight = badgeText.height + 4;
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y), width: badgeWidth, height: badgeHeight),
      const Radius.circular(4),
    );
    canvas.drawRRect(badgeRect, Paint()..color = rankColor.withValues(alpha: 0.3)..style = PaintingStyle.fill);
    canvas.drawRRect(badgeRect, Paint()..color = rankColor..style = PaintingStyle.stroke..strokeWidth = 1);
    badgeText.paint(canvas, Offset(x - badgeText.width / 2, y - badgeText.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TablePainter oldDelegate) => oldDelegate.table.id != table.id;
}
