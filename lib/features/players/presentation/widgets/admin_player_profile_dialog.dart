import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/core/services/api_service.dart';
import 'package:tournament_clock/core/models/rps_rank.dart';
import 'package:tournament_clock/features/tournament/presentation/widgets/edit_player_rps_dialog.dart';

Map<String, dynamic>? _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

List<Map<String, dynamic>> _jsonMaps(dynamic value) {
  if (value is! List) return const [];
  return value.map(_jsonMap).whereType<Map<String, dynamic>>().toList();
}

class AdminPlayerProfileDialog extends ConsumerWidget {
  final String playerId;
  const AdminPlayerProfileDialog({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<dynamic>(
      future: ApiService().get('/players/$playerId'),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AlertDialog(
            content: SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Статус: ${snapshot.error.runtimeType}'),
                const SizedBox(height: 8),
                Text(snapshot.error.toString()),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          );
        }
        final response = snapshot.data;
        if (response == null) {
          return const AlertDialog(content: Text('Игрок не найден'));
        }

        final data = _jsonMap(response.data);
        if (data == null || data.isEmpty) {
          return const AlertDialog(content: Text('Игрок не найден'));
        }

        final user = _jsonMap(data['user']) ?? data;
        final achievements = _jsonMaps(data['achievements']);
        final ratingHistory = _jsonMaps(
          data['ratingHistory'] ?? data['rating_history'],
        );

        final fullName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
        final displayName = fullName.isEmpty ? (user['login'] ?? '') : fullName;
        final rpsPoints = int.tryParse((user['rps_points'] ?? 0).toString()) ?? 0;
        final rpsRankCode = user['rps_rank'] as String? ?? 'FISH';
        final rpsRank = RpsRankX.fromCode(rpsRankCode);

        return AlertDialog(
          title: Text(displayName),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('@${user['login'] ?? ''}'),
                  Text(user['email'] ?? ''),
                  const SizedBox(height: 8),
                  Text('Телефон: ${user['phone_number'] ?? '—'}'),
                  const SizedBox(height: 8),
                  Text('Рейтинг: ${user['rating'] ?? 0}'),
                  Text('RPS: $rpsPoints ($rpsRank)'),
                  const SizedBox(height: 12),
                  const Text('Достижения', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (achievements.isEmpty)
                    const Text('Нет достижений', style: TextStyle(color: Colors.white54)),
                  for (final a in achievements)
                    ListTile(
                      dense: true,
                      leading: (a['image_url'] as String?) != null
                          ? Image.network(
                              a['image_url'],
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events_rounded),
                            )
                          : const Icon(Icons.emoji_events_rounded),
                      title: Text(a['title'] ?? ''),
                      subtitle: Text(a['description'] ?? ''),
                    ),
                  const SizedBox(height: 12),
                  const Text('История рейтинга', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (ratingHistory.isEmpty)
                    const Text('Нет истории', style: TextStyle(color: Colors.white54)),
                  for (final r in ratingHistory)
                    ListTile(
                      dense: true,
                      title: Text('Δ ${(r['delta'] as num?)?.toInt() ?? 0}'),
                      subtitle: Text(r['reason']?.toString() ?? ''),
                      trailing: Text((r['created_at']?.toString() ?? '')),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
            FilledButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => EditPlayerRpsDialog(
                    playerId: playerId,
                    playerName: displayName,
                    currentRps: rpsPoints,
                    currentRank: rpsRank,
                  ),
                );
              },
              child: const Text('Изменить RPS'),
            ),
          ],
        );
      },
    );
  }
}
