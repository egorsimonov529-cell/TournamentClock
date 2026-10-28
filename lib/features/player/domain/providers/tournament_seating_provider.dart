import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/core/services/api_service.dart';
import 'package:tournament_clock/features/tables/domain/models/seating_models.dart';
import 'package:tournament_clock/core/models/rps_rank.dart';

/// Provider для загрузки рассадки турнира из API
final tournamentSeatingProvider =
    FutureProvider.family<List<PokerTable>, String>((ref, tournamentId) async {
  try {
    final response = await ApiService().get('/tables', queryParameters: {
      'tournament_id': tournamentId,
    });

    final data = response.data;
    if (data is List) {
      return data
          .map((tableJson) => PokerTable(
                id: tableJson['id'] as String,
                name: tableJson['name'] as String,
                seats: (tableJson['seats'] as List?)
                        ?.map((seatJson) {
                          final seat = seatJson as Map<String, dynamic>;
                          final playerJson = seat['player'] as Map<String, dynamic>?;
                          return TableSeat(
                            number: seat['number'] as int,
                            player: playerJson != null
                                ? Player(
                                    id: playerJson['id'] as String,
                                    name: playerJson['name'] as String,
                                  )
                                : null,
                          );
                        })
                        .toList() ??
                    [],
              ))
          .toList();
    }

    return [];
  } catch (e) {
    print('Ошибка загрузки рассадки: $e');
    return [];
  }
});

/// Provider для загрузки незасеянных игроков турнира
final tournamentUnseatedPlayersProvider =
    FutureProvider.family<List<Player>, String>((ref, tournamentId) async {
  try {
    print('[TournamentSeating] Loading unseated players for tournament: $tournamentId');
    
    // Сначала загружаем зарегистрированных игроков
    final response = await ApiService().get(
      '/tournaments/$tournamentId/registered-players',
    );

    List<Player> players = [];
    
    if (response.data is List) {
      final playersData = response.data as List<dynamic>;
      
      // Получаем уже seated IDs
      final seatingResponse = await ApiService().get(
        '/tables',
        queryParameters: {'tournament_id': tournamentId},
      );
      
      Set<String> seatedIds = {};
      if (seatingResponse.data is List) {
        final tables = seatingResponse.data as List<dynamic>;
        for (final table in tables) {
          if (table is Map<String, dynamic>) {
            final seats = table['seats'] as List? ?? [];
            for (final seat in seats) {
              if (seat is Map<String, dynamic>) {
                final playerData = seat['player'] as Map<String, dynamic>?;
                if (playerData != null) {
                  seatedIds.add(playerData['id'] as String);
                }
              }
            }
          }
        }
      }
      
      print('[TournamentSeating] Seated IDs: ${seatedIds.length}');
      
      players = playersData
          .map((item) => item as Map<String, dynamic>)
          .where((item) => !seatedIds.contains(item['id']))
          .map(
            (item) => Player(
              id: item['id'] as String,
              name: item['name'] as String? ?? item['login'] as String? ?? 'Игрок',
            ),
          )
          .toList();
    }
    
    print('[TournamentSeating] Loaded ${players.length} unseated players');
    return players;
  } catch (e, stackTrace) {
    print('[TournamentSeating] Error loading unseated players: $e');
    print('[TournamentSeating] Stack trace: $stackTrace');
    return [];
  }
});
