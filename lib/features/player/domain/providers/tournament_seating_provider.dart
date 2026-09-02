import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/core/services/api_service.dart';
import 'package:tournament_clock/features/tables/domain/models/seating_models.dart';

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
    // ignore: avoid_print
    print('Ошибка загрузки рассадки: $e');
    return [];
  }
});
